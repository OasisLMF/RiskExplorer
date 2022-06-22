The Risk Explorer Tool - User guide
====================================================

These pages will provide a step-by-step guide to running the Risk Explorer tool and will give more general background on the tool's uses and limitations.

Introductory FAQs
-----------------------------

**What is the Oasis Risk Explorer?**

The Oasis Risk Explorer is a tool developed by the Insurance Development Forum in partnership with Oasis and Maximum Information. The central purpose of this tool is educational, serving as an introduction to the 
different considerations that go into designing and modelling catastrophe insurance covers. The model is currently in its pilot phase and a number of further features will be added before the full launch in November 
this year.

The tool aims to guide users through the different steps required in setting up and modelling a parametric insurance cover. Each of these steps is broken out into separate tabs that form the the basic building blocks 
of virtually any catastrophe model. The first three sections require input from the user to define how the insurance cover in question will work and be modelled:

* *Hazard* What type of events (e.g. windstorms/earthquakes etc.) are you modelling and what data should be used to model them?

* *Exposure* Which area are you interested in covering?

* *Vulnerability* What events will your insurance cover pay out based on and how much payout will you receive? 


The next two sections allow the user to run modelling and view output from their modelling:

* *Simulation Engine* Once hazard, exposure and vulnerability are specified this is where you can run probabilistic modelling on your cover

* *Output* This is where you can view the output of the modelling 


**What is parametric insurance?**

Parametric insurance pays out a pre-agreed amount when a certain type of event occurs in a given location or area. The amount paid to the policyholder will often be specified in "steps" determined by the magnitude or intensity of the event in question. 

Parametric insurance covers are specifically focused on in the Risk Explorer as they are commonly used in emerging economies. They are widely used due to their simplicity and the speed with which pay-outs can be worked out and distributed to policyholders compared to standard insurance covers. 

The example below gives a simplified demonstration of how a cover might work: 

A parametric insurance product is purchased by a local  authority to cover windstorm damage in a town that is prone to typhoons. The local government have some
idea of the economic cost of these types of events from previous typhoons that have hit the town in the past. They decide that they want coverage for events that are at least of category 2 strength on the Saffir-Simpson scale, as recent events have demonstrated that this is generally where the cost of such events starts to become an issue. They also want the cover to protect them from more extreme events, up to the worst event that is likely to occur in a 50 year time period. They estimate that a category 4 typhoon impacts their town roughly every 50 years, so decide to purchase cover that will be enough to reimburse them for the likely damage from this.

They decide based on their budget and their knowledge of previous events to purchase parametric insurance that covers an area of 5km radius around the centre of the town, triggers based on wind speed, and has a maximum payout amount of $10m, using the payout terms as follows:

.. list-table:: Payout terms
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

So in this example, if a wind speed greater than 154km/h but less than 178km/h is recorded within a 5km radius of the town, the local authority would receive $5m in pay-out. Similarly if a wind speed of say 180km/h was recorded, they would receive a pay-out of $7.5m.


How should this model be used?
----------------------------------

As mentioned previously, the main use of this model is as an educational tool. The way that you use this app will depend on the background knowledge you already have of risk modelling and parametric insurance. If you have no in-depth prior knowledge of the area, it is suggested that you go through the Risk Explorer in the following steps:


**Step 1: Get familiar with each tab's purpose and try and produce outputs (any outputs!).** Go through each tab with the help page open and try to understand the purpose of each section and input. E.g. why do we need to specify an exposure? Why would we want to specify an area rather than a single location? Working your way through each tab, try and get the model to produce output. Examine the outputs and try and get some idea of what they are showing and why they might have been included.

**Step 2: Purposefully change certain inputs in each tab and see what impact these have on expected payout and other outputs.** Some ideas of inputs you could experiment with changing would be:

* *Location (Exposure)*  E.g. moving your location 20km to the north?

* *Area around your Location (Exposure)*  E.g. modelling a single location vs 50km radius? 

* *Meteorological Agency (Hazard)* E.g. using Japanese meteorological data vs Chinese data for the West Pacific basin?

* *Trigger (Vulnerability)* E.g. using a pressure trigger rather than wind speed trigger?

* *Maximum Amount Insured (Vulnerability)* E.g. doubling your maximum payout?

* *Number of Steps in your Payout (Vulnerability)* E.g. looking at a cover with triggers for cat 1,3 and 5 wind speeds rather than for all categories?

* *Trigger Values at each Step in your Payout (Vulnerability)* E.g. adding 10km/h to the wind speed for each of your trigger values. 

* *Payouts at each Trigger Value (Vulnerability)* E.g. increasing your payout at lower trigger amounts vs. higher trigger amounts.

* *Number of Reinstatements (Vulnerability)* E.g. Using zero vs one reinstatement?

* *Number of Simulations (Simulation)* E.g. Running 5,000 simulations rather than 2,000?

When you change these, examine the outputs and think about whether the difference is what you would expect it to be. Also consider the reasons why it is likely to be different. Some examples of outputs to look at would be:

* *Average Payout for each measure:* What is the impact on the average historical, unweighted and weighted simulation payouts and how do they compare to each other?

* *Standard Deviation of Output:* What is the impact on the average historical, unweighted and weighted simulation standard deviations and how do they compare to each other?

* *Distribution of Payouts for each Simulation:* How has the shape of the overall payout distribution changed? You may want to pay particular attention to the extreme right of the distribution as this is where the most severe outcomes occur.

* *Return Periods of each Category of Storm:* How common is each category of storms? How big is the gap between the simulated output and the history?

* *Simulation Output* Do some basic analysis on the csv files using spreadsheet software. Do you notice any trends or patterns?

**Step 3: Speculative cover design and loss modelling.** While this tool does have the functionality to allow for basic modelling and design of real insurance covers, this is not its primary use. If you do intend to use the model in this way, it is very important that you have a solid grasp of the model's limitations and methodology. Even then, you should exercise a high degree of caution when using the tool for decision-making. 

Some examples where the Risk Explorer could be run and prove helpful in a real insurance modelling setting might be?

* *Modelling and designing covers in under-served regions with no commercial models available* There may not be any commercially available tools for some regions that sit outside of the main insurance markets. In this case the Risk Explorer may be helpful for gauging some idea of potentially reasonable pricing for the cover.

* *Sense-check for an existing commercial model* It may be useful to have an alternative view to whichever other models are being used, especially given the transparent assumptions in the Risk Explorer.

One of the reasons to be careful when using this for real-world covers is that the market prices you would likely be able to buy the insurance cover at will differ a lot from the average payouts the tool produces. In practice, insurers need to cover expenses, uncertainty risk and profit margins in the prices they charge. Prices will also be impacted by market conditions such as the competitive environment and appetite amongst insurers for writing these types of covers. As such, unless insurers have a much lower view of the underlying likely payout, it is likely that real market prices for any covers priced in the tool will be a fair  bit higher than the average payouts generated.

