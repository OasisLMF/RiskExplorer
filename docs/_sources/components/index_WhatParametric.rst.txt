.. _parametric_reference-label:

What is parametric insurance?
===============================

Parametric insurance covers are attractive to a wide range of customers due to their simplicity and the speed with which pay-outs can be calculated and distributed to policyholders compared to standard insurance covers. 

Parametric insurance pays out a pre-agreed amount of money when a payout is triggered - that is an agreed type of :ref:`event<g_event_reference-label>` occurs in an agreed location or area and its intensity or impact exceeds a pre-agree threshold. 

Parametric insurance covers can e set up in various ways - including with a single payout threshold and amount, or multiple thresholds resulting in different amounts. The amount paid to the policyholder will often be specified in "steps" determined by the magnitude or intensity of the :ref:`event<g_event_reference-label>` in question. 

The example below gives a simplified demonstration of how a cover might work. In a related project, IDF RMSG is cataloguing different examples of parametric insurance solutions. The link to that catalogue will be made available here in early 2025. 


**Example 1:** 

A parametric insurance product is purchased by a local authority or national government to cover windstorm damage in a town that is prone to typhoons. The local government have some idea of the economic cost of these types of :ref:`events<g_event_reference-label>` from previous typhoons that have hit the town in the past. 

They decide that they want coverage for events that are at least of category 2 strength on the :ref:`Saffir-Simpson<g_sscategory_reference-label>` scale, as recent events have demonstrated that this is generally where the cost of damage exceeds the government funding available from their national reserves. They also want the cover to protect them from more extreme events, up to the worst event that is likely to occur in a 50-year time period. They estimate that a category 4 typhoon impacts their town roughly every 50 years, so decide to purchase cover that will be enough to reimburse them for the likely damage from this.
They decide based on their budget and experience of previous events to purchase parametric insurance that:

1.	Covers an area of 5km radius around the centre of the town
2.	:ref:`Triggers<g_triggermeasure_reference-label>` based on wind speed 
3.	Has a maximum :ref:`payout<g_payout_reference-label>` amount of $10m 

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

In this example, if the maximum wind speed occurring in the area define in (1) was less than 154km/h occurred there would be no payout. If greater than 154km/h but less than 178km/h is recorded within a 5km radius of the town, the local authority would receive $5m in pay-out, and so on to a maximum of $10m. This type of payout structure is replicated by the “step” vulnerability curve in the Risk Explorer.


**Example 2:** 

A parametric insurance product is purchased by a local authority or national government to compensate farmers who have experienced drought. They decide that they want coverage for moderate-severe :ref:`events<g_event_reference-label>` - here characterised as with a return period of approximately 1-in-3-years or greater. They decide to implement a ramped pay out scheme, which starts to :ref:`trigger<g_triggermeasure_reference-label>` for moderate droughts, with the full pay out made for more severe droughts.  

Following a preliminary :ref:`historical loss, or 'burn' analysis<_g_historicalloss_reference-label>`, to ascertain the return periods for thresholds of the  :ref:`weather index<g_insured_index_reference-label>`, and to confirm that tshe parametric insurance will pay out during notable drought years, the following :ref:`payout<g_payout_reference-label>` terms were selected:

1.	Covers individual farmer locations on a 0.25 x 0.25 degree grid for a particularly vulnerable region of the country where the main :ref:`growing season<g_growing_season_reference-label>` is March to May.
2.	:ref:`Triggers<g_triggermeasure_reference-label>` based on percentage seasonal total precipitation for March-May. 
3.	Has a maximum :ref:`payout<g_payout_reference-label>` amount of $1000 per farmer. 

With these priorities in mind, they select the following payout terms:

.. list-table:: Example Payout Terms
   :widths: 30 30
   :header-rows: 1

   * - Percentage seasonal total precipitation
     - Pay-out
   * - 90% of seasonal climatology [Mild drought]
     - 25% of maximum ($250)
   * - 80% of seasonal climatology [Moderate drought]
     - 75% of maximum ($750)
   * - 60% of seasonal climatology [Severe drought]
     - 100% of maximum ($1000)


This type of payout structure is replicated by the “linear” vulnerability curve in the Risk Explorer.

* **Sense-check for an existing commercial model.** It may be useful to have an alternative view to whichever other models are being used, especially given the transparent assumptions in the Risk Explorer.

One of the reasons to be careful when using this for real-world covers is that the market prices you would likely be able to buy the insurance cover at will differ a lot from the :ref:`average losses<g_expectedloss_reference-label>` the tool produces. 
In practice, insurers need to cover expenses, uncertainty risk and profit margins in the prices they charge. 

Prices will also be impacted by market conditions such as the competitive environment and appetite amongst insurers for writing these types of covers. As such, unless insurers have a much lower view of the underlying :ref:`expected loss<g_expectedloss_reference-label>`, it is likely that real market prices for any covers priced in the tool will be higher than the :ref:`average losses<g_expectedloss_reference-label>` generated here. 

