The Risk Explorer Tool - User Guide and Introductory FAQs
==========================================================

These pages provide a step-by-step guide to running the Risk Explorer tool and give more general background on the tool's uses and limitations.

What is the Oasis Risk Explorer?
---------------------------------
The :ref:`Oasis<g_oasis_reference-label>` Risk Explorer is a tool developed by the :ref:`Insurance Development Forum<g_idf_reference-label>` in partnership with :ref:`Oasis<g_oasis_reference-label>` and Maximum Information. The central purpose of this tool is educational, serving as an introduction to the 
different considerations that go into designing and modelling catastrophe insurance covers. 

The model is currently in its pilot phase and a number of further features will be added before the full launch in November this year. The tool aims to guide users through the different steps required in setting up and modelling a parametric insurance cover. Each of these steps is broken out into separate tabs that form the basic building blocks of virtually any catastrophe model. 

.. figure:: ../docs_img/Intro1.png
  :scale: 50%
  :alt: Risk Explorer Tabs
  
  Risk Explorer Toolbar Displaying the Application's Different Tabs 

The first three sections (excluding the introduction and help) require inputs from the user that define how the insurance cover will work and be modelled:

* **Exposure:** Which location or area are you interested in covering?
* **Hazard:** What type of :ref:`events<g_event_reference-label>` (e.g., windstorms/earthquakes etc.) are you modelling and what data should be used to model them?
* **Vulnerability:** What :ref:`events<g_event_reference-label>` will your insurance cover pay out based on and how much :ref:`payout<g_payout_reference-label>` will you receive? 

The next two sections allow the user to run modelling and view output from their modelling:

* **Simulation:** Once :ref:`hazard<g_hazard_reference-label>`, :ref:`exposure<g_exposure_reference-label>` and :ref:`vulnerability<g_vulnerability_reference-label>` are specified, this is where you can run probabilistic modelling on your cover.
* **Output:** Once your :ref:`simulations<g_simulation_reference-label>` are complete, model outputs will display on this tab. These outputs will help you to make sense of the modelling and include downloadable data, tables, graphs and maps. 

.. _parametric_reference-label:

What is parametric insurance?
------------------------------
The :ref:`Oasis<g_oasis_reference-label>` Risk Explorer is a parametric insurance tool. Parametric insurance covers are attractive to a wide range of customers due to their simplicity and the speed with which pay-outs can be calculated and distributed to policyholders compared to standard insurance covers. 

Parametric insurance pays out a pre-agreed amount when a certain type of :ref:`event<g_event_reference-label>` occurs in a given location or area. The amount paid to the policyholder will often be specified in "steps" determined by the magnitude or intensity of the :ref:`event<g_event_reference-label>` in question. The example below gives a simplified demonstration of how a cover might work. 

*Example*

A parametric insurance product is purchased by a local authority or national government to cover windstorm damage in a town that is prone to typhoons. The local government have some
idea of the economic cost of these types of :ref:`events<g_event_reference-label>` from previous typhoons that have hit the town in the past. 

They decide that they want coverage for :ref:`events<g_event_reference-label>` that are at least of category 2 strength on the :ref:`Saffir-Simpson<g_sscategory_reference-label>` scale, as recent :ref:`events<g_event_reference-label>` have demonstrated that this is generally where the cost of such :ref:`events<g_event_reference-label>` becomes higher than the government can cover from their national reserves. They also want the cover to protect them from more extreme :ref:`events<g_event_reference-label>`, up to the worst event that is likely to occur in a 50-year time period. They estimate that a category 4 typhoon impacts their town roughly every 50 years, so decide to purchase cover that will be enough to reimburse them for the likely damage from this.

They decide based on their budget and their knowledge of previous :ref:`events<g_event_reference-label>` to purchase parametric insurance that:

1.	 Covers an area of 5km radius around the centre of the town
2.	:ref:`Triggers<g_triggervalue_reference-label>` based on wind speed 
3.	Has a :ref:`maximum payout<g_maxpayout_reference-label>` amount of $10m 

With these priorities in mind, they select the following :ref:`payout<g_payout_reference-label>` terms:

.. list-table:: Example Payout Terms
   :widths: 30 30
   :header-rows: 1

   * - Wind Speed
     - Pay-out
   * - 154km/h (category 2)
     - 50% of maximum ($5m)
   * - 178km/h (category 3)
     - 75% of maximum ($7.5m)
   * - 209km/h (category 4)
     - 100% of maximum ($10m)

In this example, if a wind speed greater than 154km/h but less than 178km/h is recorded within a 5km radius of the town, the local authority would receive $5m in pay-out. Similarly, if a wind speed of say 180km/h was recorded, they would receive a pay-out of $7.5m. Any wind speed recorded above 209km/h would result in the :ref:`maximum payout<g_maxpayout_reference-label>` amount of $10m.

How should this model be used?
----------------------------------

As mentioned previously, the main use of this model is as an educational tool. The way that you use this app will depend on the background knowledge you already have of risk modelling and parametric insurance. If you have no in-depth prior knowledge of the area, it is suggested that you go through the Risk Explorer in the following steps:

**Step 1: Get familiar with each tab's purpose and try to produce outputs (any outputs!).** Go through each tab with these help pages open and try to understand the purpose of each section and input. E.g., why do we need to specify an :ref:`exposure<g_exposure_reference-label>`? Why would we want to specify an area rather than a single location? Working your way through each tab, try and get the model to produce output. Examine the outputs and try and get some idea of what they are showing and why they might have been included.

**Step 2: Purposefully change certain inputs in each tab and see what impact these have on expected payout and other outputs.** This will help you to understand potential volatility in the output . This process should also give you an idea of the careful choices required in structuring a parametric insurance cover   that will provide cost-effective resilience. Some ideas of inputs you could experiment with changing would be:

* **Location (on the Exposure tab)**  E.g., moving your location 20km to the north?

* **Area around your Location (Exposure)**  E.g., modelling a single location vs 50km radius? 

* **Meteorological Agency (Hazard)** E.g., using Japanese meteorological data vs Chinese data for the West Pacific :ref:`basin<g_basin_reference-label>`?

* **Trigger (Vulnerability)** E.g., using a pressure trigger rather than wind speed trigger?

* **Maximum Amount Insured (Vulnerability)** E.g., doubling your :ref:`maximum payout<g_maxpayout_reference-label>`?

* **Number of Steps in your Payout (Vulnerability)** E.g., looking at a cover with triggers for cat 1,3 and 5 wind speeds rather than for all categories?

* **Trigger Values at each Step in your Payout (Vulnerability)** E.g., adding 10km/h to the wind speed for each of your :ref:`trigger values<g_triggervalue_reference-label>`. 

* **Payouts at each Trigger Value (Vulnerability)** E.g., increasing your :ref:`payout<g_payout_reference-label>` at lower trigger amounts vs. higher trigger amounts.

* **Number of Reinstatements (Vulnerability)** E.g., Using zero vs one :ref:`reinstatement<g_reinstatement_reference-label>`?

* **Number of Simulations (Simulation)** E.g., Running 5,000 :ref:`simulations<g_simulation_reference-label>` rather than 2,000?

When you change these, examine the outputs and think about whether the difference is what you would expect it to be. Also consider the reasons why it is likely to be different. Some examples of outputs to look at would be:

* **Expected Payout for each Method:** What is the impact on the :ref:`historical<g_historicalloss_reference-label>`, :ref:`unweighted<g_unweightedsimloss_reference-label>` and :ref:`weighted<g_weightedsimloss_reference-label>` simulation payouts and how do they compare to each other?

* **Standard Deviation of Output:** What is the impact on the average :ref:`historical<g_historicalloss_reference-label>`, :ref:`unweighted<g_unweightedsimloss_reference-label>` and :ref:`weighted<g_weightedsimloss_reference-label>` simulation :ref:`standard deviations<g_stdev_reference-label>` and how do they compare to each other?

* **Distribution of Payouts for each Simulation:** How has the shape of the overall :ref:`payout<g_payout_reference-label>` distribution changed? You may want to pay particular attention to the extreme right of the distribution as this is where the most severe outcomes occur.

* **Return Periods of each Category of Storm:** How common is each :ref:`category<g_sscategory_reference-label>` of storm? How big is the gap between the simulated output and the history?

* **Simulation Output** Do some basic analysis on the csv files using spreadsheet software. Do you notice any trends or patterns?

**Step 3: Speculative cover design and loss modelling.** While this tool does have the functionality to allow for basic modelling and design of real insurance covers, this is not its primary use. If you do intend to use the model in this way, it is very important that you have a solid grasp of the model's limitations and methodology. Even then, you should exercise a high degree of caution when using the tool for decision-making. 

Some examples where the Risk Explorer could be run and prove helpful in a real insurance modelling setting might be:

* **Modelling and designing covers in under-served regions with no commercial models available.** There may not be any commercially available tools for some regions that sit outside of the main insurance markets. In this case the Risk Explorer may be helpful for gauging some idea of potentially reasonable pricing for the cover.

* **Sense-check for an existing commercial model.** It may be useful to have an alternative view to whichever other models are being used, especially given the transparent assumptions in the Risk Explorer.

One of the reasons to be careful when using this for real-world covers is that the market prices you would likely be able to buy the insurance cover at will differ a lot from the :ref:`average payouts<g_expectedpayout_reference-label>` the tool produces. 
In practice, insurers need to cover expenses, uncertainty risk and profit margins in the prices they charge. 

Prices will also be impacted by market conditions such as the competitive environment and appetite amongst insurers for writing these types of covers. As such, unless insurers have a much lower view of the underlying :ref:`expected payout<g_expectedpayout_reference-label>`, it is likely that real market prices for any covers priced in the tool will be higher than the :ref:`average payouts<g_expectedpayout_reference-label>` generated here.