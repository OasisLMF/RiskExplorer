.. _howtouse_reference-label:

How should this model be used?
==========================================================

As mentioned previously, the main use of this model is as an educational tool. The way that you use this app will depend on the background knowledge you already have of risk modelling and parametric insurance. If you have no in-depth prior knowledge of the area, it is suggested that you go through the Risk Explorer in the following steps:


Step 1: Get familiar with each tab's purpose and try to produce outputs (any outputs!).
------------------------------------------------------------------------------------------------

Go through each tab with these help pages open and try to understand the purpose of each section and input. E.g., why do we need to specify an :ref:`exposure<g_exposure_reference-label>`? Why would we want to specify an area rather than a single location? Working your way through each tab, try and get the model to produce results on the event and loss analysis tabs. Examine the outputs and try and get some idea of what they are showing and why they might have been included. You may wish to start by using :ref:`stochastic<g_stochastic_reference-label>` hazard data, as the outputs are a bit easier to understand. Once you have run this, move on to using IBTrACS data.



Step 2: Experiment with certain inputs to see the impact on expected payout and other outputs.
------------------------------------------------------------------------------------------------

This will help you to understand potential variability in the output. This process should also give you an idea of the careful choices required in modelling risk and structuring insurance covers that will provide cost-effective resilience. Some ideas of inputs you could experiment with changing would be:

* **Location (on the Exposure tab)**  E.g., moving your location 20km to the north?

* **Area around your Location (Exposure)**  E.g., modelling a location with a 5km radius vs a location with a 50km radius? 

* **Asset/Policy Value (Exposure)** E.g., doubling your :ref:`asset value<g_assetvalue_reference-label>`?

* **Meteorological Agency (Hazard)** E.g., For IBTrACS data, using Japanese meteorological data vs Chinese data for the West Pacific :ref:`basin<g_basin_reference-label>`?

* **Intensity Measure (Vulnerability)** E.g., using a pressure intensity measure rather than wind speed? For drought, using a dry spell index compared to a % of climatology trigger? 

* **Number of Steps in your Vulnerability (Vulnerability)** E.g., looking at a curve with increases in :ref:`damage<g_damage_reference-label>` for cat 1,3 and 5 wind speeds rather than for all categories? 
For drought, you may also want to look at increasing the number of payout steps, e.g, if your sole stepped payout is currently at 80% of climatology, how differently does the cover respond with two steps at 70% and 80%?

* **Intensity Measure Values at each Level in your Vulnerability Curve (Vulnerability)** E.g., adding 10km/h to the wind speed for each of your :ref:`intensity values<g_intensityvalue_reference-label>`, or subtracting 5% from each percentage of climatology :ref:`intensity value<g_intensityvalue_reference-label>`

* **Damage Percentages at each Intensity Level (Vulnerability)** E.g., increasing or decreasing your :ref:`damage<g_damage_reference-label>` at lower or higher intensity measures.

* **Shape of your Vulnerability Curve (Vulnerability)** E.g., Using a linear vulnerability curve compared to a stepped curve?

* **Number of Simulations (Simulation)** E.g., Running twice as many :ref:`simulations<g_simulation_reference-label>` in the Simulation tab.

There are a few further options that may be of interest specifically when looking at drought:

* **Number of Policyholders (Exposure)** Increasing or decreasing the number of policyholders covered (this is limited to 100)

* **Growing Season Start and End Date (Vulnerability)** Growing seasons are defaults taken from Dunning et al. 2016 (https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2016JD025428), which may not be suitable in all cases. 

* **Dry Days Threshold (Vulnerability)** E.g., changing the threshold of what percentage of climatological rainfall over a 5-day period counts as "dry"

When you change each of these aspects, examine the outputs and think about whether the difference is what you would expect it to be. Also consider the reasons why it is likely to be different. Some examples of outputs to look at would be:

* **Expected Loss for each Method:** For :ref:`IBTrACS<g_ibtracs_reference-label>` hazard data, what is the impact on the :ref:`historical<g_historicalloss_reference-label>`, :ref:`unweighted<g_unweightedsimloss_reference-label>` and :ref:`weighted<g_weightedsimloss_reference-label>` simulation losses and how do they compare to each other?

* **Standard Deviation:** How does the standard deviation compare to the expected loss? For IBTrACS hazard data, what is the impact on the average :ref:`historical<g_historicalloss_reference-label>`, :ref:`unweighted<g_unweightedsimloss_reference-label>` and :ref:`weighted<g_weightedsimloss_reference-label>` simulation :ref:`standard deviations<g_stdev_reference-label>` and how do they compare to each other?

* **Distribution of Losses for each Simulation:** How has the shape of the overall :ref:`loss<g_loss_reference-label>` distribution changed? You may want to pay particular attention to the extreme right of the distribution as this is where the most severe outcomes occur.

* **Return Periods of each Category of Storm or Amount of Loss:** How common is each :ref:`category<g_sscategory_reference-label>` of storm or earthquake or total loss for drought? How big is the gap between the simulated output and the history?

* **Simulation Output** Do some basic analysis on the csv files using spreadsheet software. Do you notice any trends or patterns?

Additionally for drought you will want to consider:

* **The Number of Policyholders Impacted** What number of policyholders receive a payout of any amount

* **Geographic Distribution of Policyholders Impacted/Payouts** For larger areas of exposure, where are the largest or most payouts occurring?



Step 3: Speculative cover design and loss modelling.
------------------------------------------------------------------------------------------------

While this tool does have the functionality to allow for basic modelling and design of insurance covers, this is not its primary use. If you do intend to use the model in this way, it is very important that you have a solid grasp of the model's limitations and methodology. Even then, you should exercise a very high degree of caution when using the tool for any kind of decision-making. 

Some examples where the Risk Explorer could be run and prove helpful in a real insurance modelling setting might be:

* **Modelling parametric covers in under-served regions with no commercial models available.** There may not be any commercially available tools for some regions that sit outside of the main insurance markets. In this case the Risk Explorer may be helpful for gauging some idea of potentially reasonable 
