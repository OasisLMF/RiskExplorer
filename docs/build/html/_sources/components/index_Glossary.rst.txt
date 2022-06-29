.. _glossary_reference-label:

Glossary 
-----------------------------

**Basin (Tropical Cyclone Basin):** The distinct areas where tropical cyclones form. These are sometimes grouped slightly differently depending on the source of information. For the purposes of this app, the six basins and some of the areas that would fall into each basin are listed below.

      * North Atlantic: Covers the region around the Caribbean and the East Coast of North and Central America.
      * North Indian: Covers the Arabic peninsula, a large portion of coastal South Asia well as the  West coast of Africa. 
      * South Indian: Covers The Eastern coast of Africa and Southern Indian Ocean.
      * North-East Pacific: Covers the Western coast of Central and North America.
      * North-West Pacific: Covers a large portion of the Eastern coast of Asia and a number of islands in the Pacific ocean 
      * South Pacific: Covers Oceania.

**Event:** A particular occurrence of a natural or man-made disaster. Events can refer to real-life historical events that have actually occurred or can also refer to hypothetical or simulated events 
generated for the purposes of modelling.

**Event Set:** The event set defines all the events that can occur within a given model. E.g. for the North-West Pacific basin in the Risk Explorer, the event set is all of the tropical cyclones recorded by your  
selected meteorological agency between 1978-2021.

**Experience:** An insurance term that refers to a method of quantifying the expected insurance loss to a cover based on what has happened in the past. Generally this takes the form of an average
of the payouts that would have occurred throughout recent years, adjusting for any changes in the cover, exposure or other important external factors. "Experience" is sometimes used interchangeably with "History".

**Exposure**:

* Definition 1: Exposure is one of the key components of a catastrophe model, along with hazard and vulnerability. Exposure refers to the assets you want to insure. The exposure(s) can be defined as a specific location(s), a list of assets/buildings or an area that is to be protected by the insurance cover. This module interacts with the hazard and vulnerability modules to produce simulated insurance losses/payouts.

* Definition 2: An insurance term that refers to a method of quantifying the expected insurance loss to a cover based on the underlying assets being covered. Typically the way the exposure price is calculated will differ based on the type of asset being covered e.g. a building's construction type.

**Expected Loss/Payout:** An estimate of the loss/payout an insurance contract will generate on average. This can be calculated using any number of different methods and may be weighted based on the probabilities
of different outcomes occurring. The terms loss and payout reflect the impact on the insurer and insured respectively, i.e. the insurer makes a loss on the cover whereas the insured gets a payout to reimburse them for whatever loss was experienced. 

**Frequency:** An estimate of how often an event occurs on average. Frequencies in this tool are generally defined on an annual basis. That is, a frequency of 0.2 means that an event happens 0.2 times per year 
on average. Obviously the number of events in a given year will always be a round number, so another way of thinking about smaller decimal frequencies is to look at them as probabilities of an event happening. 
E.g. an event with a frequency of 0.2 won't happen 80% of the time and will occur 20% of the time for a given year. Note that there is some chance more than one event could occur so this estimate is not exact.

**Hazard:** Hazard is one of the key components of a catastrophe model, along with exposure and vulnerability. The main purpose of the Hazard module is to determine the level of physical risk from an event at each 
potential location of the exposure. One example of a hazard component is the IBTrACS data that feeds this model. For any area in a tropical cyclone basin, it contains a record of the historic wind speeds from 
previous cyclones. These wind speeds are used as a measure of the relative "hazard" or level of risk from a cyclone event at each location. This module interacts with the exposure and vulnerability modules to produce simulated insurance losses/payouts.

**Historical Loss:** : This is one method of generating an expected loss/payout. The method takes an average of the losses/payouts sustained over a period of history for your exposure point or area. For example, 
let's assume we have data across storms from 1978-2021. The data shows that over this period, your exposure area experienced 2 storms that would have each generated 100k USD payouts. The total is 200k averaged
over the 44 years of data, and so the average annual Historical Loss in this example would be USD 4,545.

**IBTrACS:** IBTrACS stands for International Best Track Archive for Climate Stewardship. According to their website, "IBTrACS merges Tropical Cyclone storm track datasets from agencies around the world to create 
a global, best track Tropical Cyclone database". The data is open-source and can be accessed online at https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r00/access/csv/.
IBTrACS is the main source of hazard data for the Risk Explorer at present and is compiled by the US government body, NOAA (National Oceanic and Atmospheric Administration).

**Insurance Development Forum:** The IDF is a public/private partnership led by the insurance industry and supported by international organisations. The IDF was first announced at the United Nations Conference of the Parties 
(COP21) Paris Climate summit in 2015 and was officially launched by leaders of the United Nations, the World Bank and the insurance industry in 2016.

**Latitude-Longitude:** This term is often abbreviated to lat-long. Latitude and longitude can be thought of as a global coordinate system, any location on the earth's surface can be defined by a given pair of latitude
and longitude values. Longitude can be thought of as how far east or west a location is, while latitude represents how far north or south a location is. Longitude values range from 180 degrees East (+180) to 180 degrees West (-180), 
with the Greenwich meridian lying at zero. Unlike latitudes, longitudes repeat on themselves, -180 and +180 represent the same point (the international date line). Latitude values can range from 90 degrees South (-90) to 90 
degrees North(+90), a latitude of 0 means that a location lies on the equator.  

**Maximum Insured/Limit:** The maximum amount that can be paid out by a cover when an event occurs. Note that the maximum insured does not always represent the total aggregate amount insured, as the maximum insured could 
be paid out multiple times if the cover has reinstatements.

**Meteorological Agency:** Meteorological agencies are government bodies that take their own measurements of tropical cyclone wind speeds and tracks which are then uploaded into IBTrACS. Data can be loaded from a number
of agencies to be used in the Risk Explorer. The below provides a list of the shorthand names of each agency and a more detailed description of each:

* USA: Any US meteorological agency
* Tokyo: RSMC (Regional Specialised Meteorological Centre) Tokyo 
* CMA: Chinese Meteorological Administration
* HKO: Hong Kong Observatory
* NewDelhi: RSMC (Regional Specialised Meteorological Centre) New Delhi, India
* Reunion: RSMC (Regional Specialised Meteorological Centre) La Reunion
* BoM: Australian Bureau of Meteorology
* Nadi: RSMC (Regional Specialised Meteorological Centre) Nadi, Fiji
* Wellington: TCWC Wellington, New Zealand

**Oasis:** Oasis is a not-for-profit company, owned by close to 30 insurers, reinsurers and brokers. Its aim is to open up catastrophe modelling by increasing both the user-base and supply. The company was founded 
in 2012 and aims to build a wider community of those interested in catastrophe risk across business, academia and government. 

**Payout/Loss:** Payout refers to the amount received by a policyholder when an event triggers their policy. Note that this does not factor in any premium originally paid for the policy. The more standard term 
in the industry for this is "loss", however this is a more insurer-centric way of defining things as for the insured themselves an event represents a payout. You may note that payout and loss are used somewhat 
interchangeably here in order to expose users to the more intuitive definition as well as the standard market terminology.

**Percentage of Maximum Insured:** A method of stating the loss/payout from a cover by expressing it as a percentage of the maximum insured. The reason for expressing losses in this way is it enables us to compare 
the relative burden of losses for different covers regardless of the financial amount. It is also useful for comparing the relative likelihood of seeing losses/payouts from different covers. 

E.g. Consider a cover with only one trigger of USD 100,000. The simulated loss is 20,000 which is 20% of the maximum. This 20% gives us an idea of the frequency of events hitting the cover, i.e we would expect a loss roughly 20% or every 1 in 5 years. A separate cover with a trigger of 1,000,000 also has a simulated loss of 20,000 
representing 2% of the maximum. We can see from the small percentage that this is quite a remote cover that we would only expect to see a loss from roughly every 1 in 50 years.
This simplification works very well with single trigger covers as we can directly pull out the frequency of losses. With multiple triggers we have to be a little more careful generalising as there are payouts 
at levels other than the maximum however it should still give a good idea of how likely the cover is to pay out.

**Peril:** A peril is a specific type of disaster that can lead to an insurance loss. Examples of peril types might include:

* Tropical Cyclone
* Flooding
* Earthquake
* Wildfire
* Extra-Tropical Cyclone
* Convective Storm 
* Winter Storm

Note that our definition within the risk explorer is limited to natural perils, however insurance covers can also include man-made perils such as building fire, terrorism or theft. 

**Reinstatement:** A reinstatement refers to a "reinstatement of cover". Reinstatements allow you to receive a payout once you have "used" up your cover i.e. received the maximum payout over the 
course of a year. The number of reinstatements dictates how many additional times you can receive the total maximum payout in a year. 
If you have zero reinstatements, the cover will only pay up to your maximum once in a given year. Subsequent events after the maximum payout has been reached will only generate further payouts if your cover 
reinstates. If you have one reinstatement, you would receive a payout for up to two maximum payout events. 

A similar logic applies for the case of partial payouts. For example, say you receive 60% of your maximum payout from an event, then a second event that year also generates a 60% loss. In the case where you had 
a reinstatement you would receive the full amount of 60% for the second event as the cover would reinstate and you would be entitled to an additional maximum payout over the course of the year. If you had no 
reinstatements, the payout for the second event would be capped at 40%. This is because the sum of your payouts for the first and second events would exceed the maximum of 100%, as such, the second payout 
is capped so as not to exceed the maximum insured. The pricing for a cover with multiple reinstatements will differ to that of a single event cover (no reinstatements).

**Return Period:** Return Period refers to the average time you would have to wait before observing a given event. E.g a return period of 5 years for a cat 2 storm means you would expect 
to have one storm at cat 2 or above every 5 years on average. Of course this is an average, and it is possible to have two 100-year events occur in subsequent years. Another way to think about return periods 
is the probability of occurrence in any given year. A 10-year return period means there is a roughly 1 in 10 (10%) chance of an event happening in any given year. For relatively remote events, return periods can be considered the reciprocals
of frequencies e.g. an event with a frequency of 0.1 has a return period of around 10 years as 1 / 0.1 = 10. 

**RMW (Radius of Maximum Wind Speeds):** The radius of maximum wind (RMW) is the distance between the centre of a cyclone and its band of strongest winds. This is an important consideration for the Risk Explorer as 
it tells us how wide an area maximum wind speeds are likely to be recorded in. For the purposes of the app, the assumed radius of maximum wind speeds is assumed to be 75 km. 

**Simulation:** A simulation typically refers to a specific "run" of a model. A run will produce a distinct set of outcomes generated by a simulation model. 
In the case of version 1 of the Risk Explorer, we are trying to simulate insurance losses at a randomly sampled location over the history of the IBTrACS data-set. As such, 
one "simulation" can be thought of as the average losses generated at one distinct simulated location. A large number of simulations are typically required to get a reliable result, hence
500 is the minimum number of simulations that can be run in the model.

**Simulation-Year:** Within the Risk Explorer, a simulation-year refers to the losses sustained in a given historical year of the hazard data for a given simulation. For example 5-2003 refers to the 2003 losses
in simulation 5. In order to generate expected losses for each simulation, we need to average across all years within that simulation.

**Saffir-Simpson Category:** A Saffir-Simpson category represents a level of hurricane intensity on the Saffir-Simpson scale which is commonly used by meteorologists and the insurance industry. The Saffir-Simpson scale
uses the measurement of sustained 1 minute maximum wind speeds to categorise hurricanes by intensity. The categories range from 1-5 with 5 being the highest intensity and 1 the lowest. Note that a category 1 hurricane still 
represents a strong storm and the majority of tropical storms are far weaker than a category 1. The table below shows the relevant wind speeds for each category:

.. list-table:: Saffir-Simpson Categories 
   :widths: 30 30 30 
   :header-rows: 1

   
   * - Category
     - km/h
     - mph 
   * - 1
     - 119-154
     - 74-96
   * - 2
     - 154-178
     - 96-111
   * - 3
     - 178-209
     - 111-130
   * - 4     
     - 209-252
     - 130-157
   * - 5
     - >252
     - >157

It's worth noting that while the Saffir-Simpson scale is a useful tool for measuring hurricane intensity, it does not include the impact of flooding or storm surge. These variables can vary a lot by storm 
and can have a serious impact on economic and insured losses.

**Simulated Loss/Payout Rank:** After all simulations have been run, the average losses for each simulation are ordered from highest to lowest. The simulation with the highest average loss would be ranked 1st, the 
next highest 2nd and so on. 

**Standard Deviation:** Standard deviation is a measure of the amount of variation that exists in a data set. The higher this number, the more spread out the data generally is from the mean or average. The lower 
the standard deviation, the more observations tend to be close to the mean value. The formula for calculating this can be found online and is available in nearly all spreadsheet applications. For nearly all 
distributions, 75% or more of observations will lie within 2 standard deviations of the average value and at least 89% will lie within 3 standard deviations. 

**Stochastic:** Events that are stochastic follow a random distribution or pattern, however aren't exactly forecastable. This term is often used in the context of an event set. 

**Trigger Measure:** The trigger measure is the event-specific measurement that will be used to determine whether an event leads to a payout or not. The trigger measurement chosen should closely relate to 
the intensity of the event and the likelihood of it causing a loss. For example, wind speed or pressure would be suitable triggers for a storm, as they closely relate to the amount of damage likely to be 
caused to the exposure of interest. Recordings of the trigger measure within your defined exposure area will determine how much payout is received in an event. 

**Trigger Values:** The value(s) which the trigger measure must exceed for an event to generate a payout for the insured. Each trigger value will have a pre-defined payout associated with its exceedance, with
payouts generally increasing with the intensity of the trigger measure. E.g. a category 1 storm might generate a payout of 5m whereas a category 2 storm might generate a payout of 10m. A cover with only one 
trigger value and one payout is known as a binary cover. 

**Unweighted Simulation Loss:** This is the average annual insurance payout across all simulations with no weighting for proximity to the exposure applied. The downside of using this method is that it may unduly
weight simulations a long way from the exposure. However it can be useful point of comparison to the weighted simulation loss, as it will give us an idea of how much impact the weighting function is having on the metric.

**Vulnerability:** Vulnerability is one of the key components of a catastrophe model, along with exposure and hazard. Vulnerability defines how physical events translate into damage/financial loss. In the case of 
a parametric cover, the financial loss is solely defined by your triggers/insurance structure because given values of your trigger measure lead to specific payouts. As such, for a parametric cover, vulnerability and 
the insurance structure itself are essentially the same thing. This module interacts with the exposure and hazard modules to produce simulated insurance losses/payouts.

**Weighting/Weighting Function:** The weighting function is a formula that takes the distance of the simulation from the initial exposure as an input and produces a weight between 0 and 1 to apply to the 
simulation as an output. The idea is to give a higher weighting to observations that lie closer to the exposure in the final calculation. There are a number of potential weighting methods that could be used
to do this. An exponential weighting function with a lambda parameter of 3.2 is selected for calculating the weightings in this model based on scientific and actuarial expert judgement. 

**Weighted Simulation Loss:** This is the average annual insurance payout across all your simulations including the weighting for proximity to the exposure applied. This is one of the main 
outputs from the simulation approach. See the :ref:`sim_workings_reference-label` in the FAQs section for a more detailed discussion of how this is calculated.


