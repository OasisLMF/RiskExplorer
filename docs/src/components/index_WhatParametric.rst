.. _parametric_reference-label:

What is parametric insurance?
===============================

Parametric insurance covers are attractive to a wide range of customers due to their simplicity and the speed with which pay-outs can be calculated and distributed to policyholders compared to standard insurance covers. 

Parametric insurance pays out a pre-agreed amount when a certain type of :ref:`event<g_event_reference-label>` occurs in a given location or area. The amount paid to the policyholder will often be specified in "steps" determined by the magnitude or intensity of the :ref:`event<g_event_reference-label>` in question. The example below gives a simplified demonstration of how a cover might work. 

The :ref:`Oasis<g_oasis_reference-label>` Risk Explorer is an educational tool that enables you to model simple parametric covers using the vulnerability tab.


**Example 1:** 

A parametric insurance product is purchased by a local authority or national government to cover windstorm damage in a town that is prone to typhoons. The local government have some idea of the economic cost of these types of :ref:`events<g_event_reference-label>` from previous typhoons that have hit the town in the past. 

They decide that they want coverage for :ref:`events<g_event_reference-label>` that are at least of category 2 strength on the :ref:`Saffir-Simpson<g_sscategory_reference-label>` scale, as recent :ref:`events<g_event_reference-label>` have demonstrated that this is generally where the cost of such :ref:`events<g_event_reference-label>` becomes higher than the government can cover from their national reserves. They also want the cover to protect them from more extreme :ref:`events<g_event_reference-label>`, up to the worst event that is likely to occur in a 50-year time period. They estimate that a category 4 typhoon impacts their town roughly every 50 years, so decide to purchase cover that will be enough to reimburse them for the likely damage from this.
They decide based on their budget and their knowledge of previous :ref:`events<g_event_reference-label>` to purchase parametric insurance that:

1.	 Covers an area of 5km radius around the centre of the town
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

In this example, if a wind speed greater than 154km/h but less than 178km/h is recorded within a 5km radius of the town, the local authority would receive $5m in pay-out. Similarly, if a wind speed of 180km/h was recorded, they would receive a pay-out of $7.5m. Any wind speed recorded above 209km/h would result in the maximum payout amount of $10m.
This type of payout structure is replicated by the “step” vulnerability curve in the Risk Explorer.


**Example 2:** 

A parametric insurance product is purchased by a local authority or national government to compensate farmers who have experienced drought. They decide that they want coverage for moderate-severe :ref:`events<g_event_reference-label>` - here charaacterised as with a return period of approximately 1:3 or greater. They decide to implement a ramped pay out scheme, which starts to :ref:`trigger<g_triggermeasure_reference-label>` for moderate droughts, with the full pay out made for more severe droughts.  

Following a preliminary :ref:`historical burn analysis<g_burn_reference-label>`, to ascertain the return periods for thresholds of the  :ref:`insured index<g_insured_index_reference-label>`, and to confirm that the :ref:`insured index<g_insured_index_reference-label>` will pay out during notable drought years, the following :ref:`payout<g_payout_reference-label>` terms were selected:

1.	Covers individual farmer locations on a 0.25 x 0.25 degree grid for a particularly vulnerable region of the country where the main :ref:`insured index<g_growing_season_reference-label>` is between March - May.
2.	:ref:`Triggers<g_triggermeasure_reference-label>` based on percentage seasonal total pecipitation for March-May. 
3.	Has a maximum :ref:`payout<g_payout_reference-label>` amount of $1000 per farmer 

With these priorities in mind, they select the following :ref:`payout<g_payout_reference-label>` terms:

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


pricing for the cover.

* **Sense-check for an existing commercial model.** It may be useful to have an alternative view to whichever other models are being used, especially given the transparent assumptions in the Risk Explorer.

One of the reasons to be careful when using this for real-world covers is that the market prices you would likely be able to buy the insurance cover at will differ a lot from the :ref:`average losses<g_expectedloss_reference-label>` the tool produces. 
In practice, insurers need to cover expenses, uncertainty risk and profit margins in the prices they charge. 

Prices will also be impacted by market conditions such as the competitive environment and appetite amongst insurers for writing these types of covers. As such, unless insurers have a much lower view of the underlying :ref:`expected loss<g_expectedloss_reference-label>`, it is likely that real market prices for any covers priced in the tool will be higher than the :ref:`average losses<g_expectedloss_reference-label>` generated here. 

