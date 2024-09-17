.. _simsWII_reference-label:

Weather Index - How does the simulation methodology Work?
==========================================================

Basic Description – Weather Index with CHIRPS Data
-------------------------------------------------------
This section provides a basic overview of how the simulation method works for :ref:`IBTrACS<g_CHIRPS_reference-label:>` hazard data.

For the drought parametric insurance, to understand potential size of payouts and year to year variability, the number and value of payouts resulting from drought occurrence are simulated for each year in the timeseries of CHIRPS data.

The simulation method can be broken down into a few distinct steps: 

**Step 1: Randomly select a number of different latitude-longitudes within the area in which the scheme will be implemented:** 
The user selects the number of policies and the number of locations to model within a defined area. The Risk Explorer allocates a set of random locations within the area of exposure and allocates a number of insured households to each locality. The locality allocations are altered for each year in the simulation.
 
**Step 2: Record the financial value of the payouts at each location and for each simulation year:** This step involves looking at the events in the hazard data. The events are based on the user designed index, set up in the vulnerability tab. The losses for each event are then recorded by checking the drought index for the simulation year against your vulnerability curve. The years used are 1984-2020.

**Step 3: Average the payouts for each year and for each simulation across the historical time series:** This gives us an average total payouts for each year and for each simulation - illustrating the variability in payouts to which the insurer is exposed.

**Step 4: Apply a weighting between 0 and 1 to the average loss for each simulation.** 
Under development

**Step 5: Calculate the weighted average of the simulated average losses for each location calculated in the earlier steps.** 
Under development



Detailed Steps – Weather Index with CHIRPS Data
----------------------------------------------------

The next section goes through each of these steps in more detail and attempts to explain why each step is necessary to the approach.

**Step 1: How and why do we sample different locations?** 

When setting up Weather Index Insurance, the insurer cannot know in advance where, within the area for which the scheme is operated, individual policies will be held. Particularly over large regions, there is considerable variability in precipitation, even within a single growing season. It is important, when calculating potential losses, to account for this variability.

In the Risk Explore, to sample the points included in a simulation:

* the user specifies:
  * a rectangular region over which the insurance scheme will be run
  * the number of localities
  * the total number of policies insured
* latitude-longitude locations are randomly selected, within the exposure area
* the number of people living at each location is randomly allocated. Note that the system ensures that the total number of policies and number of localities is as specified by the user.




**Step 2: How do we calculate losses / financial payout for each simulated location and simulation year?**

The financial value of the payouts is determined by the index and vulnerability specified by the user. In this system, we have implemented two styles of index.

**Percentage of Climatology** is based on seasonal total rainfall anomaly:
* Define the season over which the index will be calculated by specifying the start and end month for the season of interest
* Calculate the climatological precipitation for every sampling location in the simulation and simulation year, calculate the mean cumulative rainfall for over all of the years included in the  climatology timeseries.
* Calculate the index value for every sampling location in the simulation and simulation year by expressing the cumulative precipitation in the year and locality as the percentage of the climatology

**Number of Dry Days** is based on the duration, number and severity of dry spells:
* Define the season over which the index will be calculated by specifying the start and end month for the season of interest
* Specify the severity of anomaly that is considered dry. The anomaly is expressed as a % climatology for the pentad
* Specify the length of consecutive dry pentads that would be considered a dry spell
* Calculate the index value for every simulation locality and year, by counting the number of pentads that are included in the dry spells during the season of interest

At each simulation locality (determined in Step 1) and for each simulation year, once the indices have been calculated, the payout is determined by checking the weather index value against the user specified vulnerability curve. For drought insurance, the vulnerability curve determines the upper and lower bounds of the trigger threshold for each index, and the percentage of maximum payout is calculated by linearly interpolating between these bounds.



**Step 3: How do we get an expected loss for each simulation?**
The total payout across the region for each simulation and each simulation year are the sum of the payouts at each locality (derived in Step 2), multiplied by the number of people living at the locality


**Step 4: How do we weight each simulation?**
Under development



Seasonality
------------
Drought insurance most commonly aims to protect households against the impact of drought on crop cultivation. For this reason, it tends to implemented over local growing seasons, which in the tropics, coincide with the rainy seasons. In the global tropics, the timing of the growing seasons varies spatially, even within individual countries. Furthermore, in some regions, such as East Africa and Pakistan, there is more than one growing season per year. Within the Risk Explorer tool, it is not possible to vary the selected season within the region of interest, and therefore it is important to choose a region that is small enough to have a single common growing season. 

Within the Risk Explorer, the user can either specify a season over which the index will be calculated or accept the suggested defaults. The default seasons are calculated for a point in the middle of the user specified region, using the method implemented by `Dunning et al. (2016) <https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2016JD025428>`_, based on a methodology originally proposed by `Liebmann et al. (2012) <https://journals.ametsoc.org/view/journals/clim/25/12/jcli-d-11-00157.1.xml>`_.
