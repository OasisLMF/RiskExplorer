How does the Simulation Methodology Work?
====================================================

Basic Description
-----------------------

This is a relatively in-depth description of how the simulation methodology calculates expected losses/payouts and other metrics. For a more high-level overview, please consult the simulation page user instructions or in-app help text.

The simulation method can be broken down into a few distinct steps: 

* Step 1: Randomly select a number of different latitude-longitudes near the area of exposure. The number of locations sampled is entered in the simulation tab. Each random selection of a latitude-longitude is known as a "simulation". 

* Step 2: Record the payouts generated for each simulation in each year of the historical data. This step involves looking at the events in hazard data (IBTrACS in our case) and seeing which storms would have exceeded the relevant vulnerability triggers. The relevant payouts for each event are then recorded by checking against your vulnerability. The years 1978-2021 are used for all basins here except the North Atlantic.

* Step 3: Average the payouts across all years in the historical data for each simulation. This gives us an average over all the simulation-years for each simulation in the history. Each observation of a particular year in the history for a given simulated location is known as a "simulation-year".

* Step 4: Apply a weighting between 0 and 1 to the average payout for each simulation. The weighting is based on how far away the simulated location is to the exposure (e.g. a simulation that was very close might get a weighting of 0.9, one that was far away might get a weighting of 0.1).

* Step 5: Work out a weighted average of the simulated average payouts for each location calculated in the earlier steps. This is the "Weighted Simulation Loss".



Detailed Steps
------------------

The next few sections go through each of these steps in more detail. 

**Step 1: How and why do we sample different locations/lat-longs?**

It may seem odd to randomly select locations that are different to your exposure, however this is an important step which prevents over-generalising from a limited history and is the founding principle of all catastrophe models. For example, if your exposure is within a very small area or is a single location, you could have been relatively lucky and not had any significant wind events despite a number having just missed in the past 30 years. If we just used the history at the exposure point, we would assume there is zero risk when this is clearly not the case.

When randomly sampling these points, what sort of limits should we apply on the types of locations we sample? Clearly it wouldn't make sense to randomly select points anywhere the world as most of these would have very different weather patterns to our exposure and may not even be located in the same tropical cyclone basin. 

The method used here only looks at locations that are within 5 times the average radius of maximum wind speeds (also known as RMW) from a tropical cyclone. If you're modelling an area, then the radius of this is added on to the RMW before multiplying (so zero for a single location). Written as a formula, the sampling area looks like this: 

Distance from exposure to sample from = 5 x (Radius of Maximum Wind Speed of a Tropical Cyclone + Radius of Exposure)

The average radius of maximum wind speed is an important figure, as it is assumed if a location sits within this radius then the location is "hit" by the storm. It is assumed in this model that the Radius of Maximum Wind Speed figure is 75km, based on a review of a number of academic papers and expert scientific judgement. As an example, if we were modelling a single location, we would look to sample any lat-longs that are within 5 x (75 + 0) = 375km of the exposure. By contrast if we were looking to model an area with a radius of 50km, we would draw sample locations from points within 5 x (75 + 50) = 625km of the exposure

Five times the RMW is selected as this gives a good spread over the area to capture variability in nearby weather patterns. The area is also not so large that we are sampling from observations that are not relevant.

Random numbers are selected for each simulation for latitudes and longitudes that lie within the distance calculated above. These are then used in the subsequent calculations and represent our simulated locations.

**Step 2: How do we calculate payouts for each simulated location?**

Now that we have our simulated locations, we need to check these against the storm tracks from the IBTrACS hazard data. We will then be able to work out which events would have historically led to losses. This is done by drawing a 75km radius around each sampled location and checking which storms in the history would have passed through this circle. If a storm's track has taken it within 75km of the location, then it is assumed that this would have affected the location and potentially led to a payout. As mentioned in the section above, 75km represents the RMW and it is assumed if a location sits within this radius then the location is "hit" by the storm.

Maximum wind speeds recorded within the circle for each event are checked against relevant triggers from the vulnerability tab, these are then used to calculate the appropriate payouts for each event. The payouts generated by each storm are then recorded, giving us a complete history of all storms impacting each simulated location over the years. 

Consider an example where we run two simulations using a cyclone hazard dataset that covers three years of data (2019-2021). The cover being looked at has one trigger set at 178km/h which leads to a payout of 100,000 USD when a qualifying event occurs. The cover also has no reinstatements. The table below gives an idea of how the steps described above would work in practice, each row is an event in the hazard dataset that lies within a reasonable distance of the exposure.

.. list-table:: List of Hazard Data Events and Payouts
   :widths: 30 30 30 30 30 30
   :header-rows: 1

   * - Row Number 
     - Simulation Location Number
     - Simulation-Year
     - Max Wind Speed
     - Distance from Location
     - Payout (USD) 
   * - 1
     - 1
     - 2019
     - 185km/h
     - 50km
     - 100,000
   * - 2
     - 1
     - 2019
     - 200 km/h
     - 25km
     - 100,000
   * - 3
     - 1
     - 2020
     - 220km/h
     - 90km
     - 0
   * - 4
     - 1
     - 2021
     - 190km/h
     - 45km
     - 100,000
   * - 5
     - 2
     - 2019
     - 185km/h
     - 40km
     - 100,000
   * - 6
     - 2
     - 2021
     - 140km/h
     - 35km
     - 0

The event in row 3 doesn't generate a payout despite exceeding the trigger, as it lies further than 75km away from location 1 and is therefore deemed to have not affected it. The event in row 6 doesn't generate a
loss either as the wind speed is below the trigger amount of 178km/h.

**Step 3: How do we get an expected payout for each simulation?**

The individual event payouts calculated in Step 2 are then added up by simulation-year, giving a picture of the total payout generated across each year of the history for each location. This is also where any reinstatement capping would apply. 

Once we have the payouts for each year of this history, it is simply a case of averaging across these to get an average payout for each simulation. This is all we need to give us one view of the expected payout, the unweighted expected loss, which is a simple average of the payout from each simulation. 

Going back to the example in step 2, the table below shows how we get from the event data to a table of losses by simulation-year. 

.. list-table:: Payouts by Simulation-Year
   :widths: 30 30 30 30 30    
   :header-rows: 1

   * - Row Number 
     - Simulation Location Number
     - Simulation-Year
     - Payout (USD) Before Reinstatement Capping
     - Payout (USD) After Reinstatement Capping
   * - 1
     - 1
     - 2019
     - 200,000
     - 100,000
   * - 2
     - 1
     - 2020
     - 0
     - 0
   * - 3
     - 1
     - 2021
     - 100,000
     - 100,000
   * - 4
     - 2
     - 2019
     - 100,000     
     - 100,000
   * - 5
     - 2
     - 2020
     - 0
     - 0
   * - 6
     - 2
     - 2021
     - 0
     - 0
     
Notice that all years are listed here including those with no relevant events/payouts. The impact of having no reinstatements on the cover is shown in row 1. 100,000 is the maximum payout, and because this has already been breached by the first event in the year, the total loss is capped at this level and no further payout is generated by the second event. If there had been a reinstatement on the cover, the payout would have been capped at 200,000 as it would be assumed that the cover re-instated once. 

The next step is then to calculate a historical average across all years for each simulation.

.. list-table:: Payouts by Simulation
   :widths: 30 30 30
   :header-rows: 1

   * - Row Number 
     - Simulation Location Number
     - Average Payout (USD) After Reinstatement Capping
   * - 1
     - 1
     - 200,000 / 3 = 66,666.7
   * - 2 
     - 2
     - 100,000 / 3 = 33,333.3
   * - 3
     - Unweighted Simulated Loss
     - (33,333.33 + 66,666.7) / 2 = 50,000

For each simulation we are taking the total reinstatement capped losses from the previous table and dividing these by the number of years of data to get an average. 2019-2021 is three years of data, hence the denominator of 3 above. This now gives us an average payout for each simulation, taking a straight average across the two simulations gives us the unweighted expected loss which is displayed in row 3. This assumes all simulations are given identical weight regardless of how far they are from the exposure. 

**Step 4: How do we weight each simulation?**

To get a view that takes into account the distance of the simulations from the exposure, we need to work out how to appropriately weight each simulation. Simulations nearer the exposure are likely to be more relevant and generalisable than those further away. As such, closer locations should be given higher weights in the expected payout calculation. There are a number of potential weighting methods that could be used here so it's worth bearing in mind that there is a certain degree of judgement in this step.

An exponential weighting function with a lambda parameter of 3.2 has been selected for calculating the weightings in this model based on scientific and actuarial expert judgement. The table below shows the different weightings for a single location at intervals of 75km away from the exposure to give some idea of how the weighting changes in practice:

.. list-table:: Weighting Examples
   :widths: 30 30 30
   :header-rows: 1

   * - Row Number 
     - Distance from Exposure
     - Exponential Weighting
   * - 1
     - 0
     - 100%
   * - 2 
     - 75
     - 53%
   * - 3 
     - 150
     - 28%
   * - 3 
     - 225
     - 15%
   * - 3 
     - 300
     - 8%

There are a few desirable properties to this function and parameterisation which makes the exponential a good choice. These are highlighted below:

* The weighting decreases at a constant rate as we move away from the exposure. For a single location, the weighting decreases around 19% in relative terms every 25km we move away from the exposure. E.g. The weighting at 100km from the exposure is 43%, which is a 19% decrease from the 53% weighting for a location 75km from the exposure.

* The weighting function drops off quickly initially but the absolute decrease in weights slows as we get further away. The reason for this is there is likely to be a bigger gap in usefulness of an observation 0km vs 75km away compared to one being 300km vs 375km away.

* The weighting approaches zero as we get towards the edge of the potential sampling area.

The most intuitive way to think of the weightings themselves is in relative terms. A weighting of 0.8 can be thought of as 80% of the potential maximum weighting, but it can also be interpreted as being given 8 times more weight in the final calculation than an observation weighted at 10%.

Returning to our example in the earlier steps, these are the weightings that would be applied to each location:

.. list-table:: Weightings by Simulation 
   :widths: 30 30 30
   :header-rows: 1

   
   * - Simulation Location Number
     - Distance from Exposure
     - Weighting 
   * - 1
     - 125km
     - 34%
   * - 2
     - 200km
     - 18%

A detailed understanding of how the exponential function is calculated is not necessary to use the tool, however if you are interested in learning more about this, you can consult the appendix section.

**Step 5: How do we calculate the Simulated Weighted Payout?**

The last step in getting our Simulated Weighted Payout is calculating a weighted average. The payouts for each simulation are scaled by their weightings and then divided by the sum of all weightings. 

Returning to the earlier example, we can now calculate the simulated weighted payout:

.. list-table:: Weightings by Simulation 
   :widths: 30 30 30 30 30
   :header-rows: 1

   
   * - Simulation Location Number
     - Distance from Exposure
     - Weighting 
     - Average Payout (USD) After Reinstatement Capping
     - Weighting x Average Payout
   * - 1
     - 125km
     - 34%
     - 66,666.7
     - 0.34 x 66,666.7 = 22,944
   * - 2
     - 200km
     - 18%
     - 33,333.3
     - 0.18 x 33,333.3 = 6,049
   * - Simulated Weighted Payout
     -
     -
     - (22,944 + 6,049) / (34%+18%) = 55,159
     - 

In this case the expected weighted payout is 55,159. Note that this is higher than the expected unweighted payout of 50,000 which was calculated in step 3. The reason for this difference is that
simulation 1 which had a higher average loss was given a higher weight in the calculation than simulation 2 which was lower. The reason for weighting location 1 higher is that it is closer to the exposure than location 2. 
In the unweighted calculation we implicitly assume all simulations have identical weighting so this generates a lower amount of loss. 

The Weighting x Average Payout column doesn't really have a practical interpretation but is shown to illustrate the different steps. The reason we need to divide by the sum of the weightings in the final calculation
is to ensure we aren't understating the total loss. If we just added together the Weighting x Payout column, this number wouldn't account for the potential for a number of different weightings to emerge from the 
simulation process. This comes back again to the idea that the weightings themselves have more meaning when considered relative to one another, the sum of all weightings will differ each time a set of simulations 
is run so they need to be scaled accordingly.

**Appendix: Extra Information on exponential weighting function calculation**

Placeholder Text.


