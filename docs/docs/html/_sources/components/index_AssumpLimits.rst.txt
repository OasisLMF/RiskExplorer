Assumptions and Limitations – IBTrACS Hazard Data
==================================================


Assumptions and Limitations - IBTrACS
------------------------------------------------------------
There are a number of limitations that should be considered when using this model. Bear in mind that this section is largely focused on the simulation method and data cleaning process:

* **IBTrACS sampling method does not handle inland decay well:** If an :ref:`exposure<g_exposure_reference-label>` is located near a large inland area, the model may understate the likelihood of :ref:`losses<g_loss_reference-label>`. This is because tropical cyclones tend to decay as they move inland and lose their main source of fuel. Any samples taken over land will likely see lower storm activity, so if these contribute significantly to the :ref:`expected loss<g_expectedloss_reference-label>`, this may end up being understated. The :ref:`weighting function<g_weighting_reference-label>` will correct for this to some degree as more inland areas are likely to be further away, but this does not completely resolve the issue. 

* **Older hazard data may be of limited relevance with a shifting climate:** Given changing climate conditions, the expected magnitude/:ref:`frequency<g_frequency_reference-label>` of tropical cyclones could have increased or decreased in a given :ref:`basin<g_basin_reference-label>` over the :ref:`hazard<g_hazard_reference-label>` data's recording period. There is a risk that the inclusion of some of the earlier data-years in our simulation approach may lead to us understating or overstating the :ref:`expected loss<g_expectedloss_reference-label>` as they reflect fundamentally different cyclone formation conditions. This is a particular issue for the North Atlantic basin where data goes back to 1948, over 70 years ago. 

* **Linear interpolation of tracks is likely to be inaccurate:** Cubic spline is a more appropriate method for :ref:`interpolating<g_interpolation_reference-label>` these tracks and matches the scientific data better. Linear :ref:`interpolation<g_interpolation_reference-label>` is easier to calculate but the cubic spline adjustment will be looked into for further releases. 

* **Inconsistencies in max wind speed measurements between agencies:** Different measurement periods of max wind speeds are used by each :ref:`agency<g_agency_reference-label>`. As such, it may be misleading to compare output from one :ref:`agency's<g_agency_reference-label>` data to another. To give an example, RSMC Tokyo record 10 minute maximum wind speeds whereas US agencies use 1 minute maximum wind speeds. As such we'd typically expect to see higher losses using the US data set as maximum wind speeds do not need to be sustained for as long (assuming there are no major underlying differences in data collection aside from this). It's also worth noting that the time interval for the maximum wind speed is not specified in the :ref:`vulnerability<g_vulnerability_reference-label>` section, so implicitly we are assuming the same time interval as used by the :ref:`agency<g_agency_reference-label>` we are referencing.

* **Some exposures are impacted by multiple cyclone basins:** The tool currently only allows for one :ref:`basin<g_basin_reference-label>` to be modelled at a time, but in practice certain areas can be impacted by storms from multiple basins. This is particularly an issue for Central America.

* **Weighting Function:** An exponential :ref:`weighting function<g_weighting_reference-label>` is used here with parameterisation selected using expert judgement. There are likely a range of "reasonable" weighting functions that could be applied and there is ultimately no way of knowing whether the weighting function selected is indeed the most appropriate one.

* **Assumption of radius of maximum wind speed is constant by basin and landfall location:** In reality this will vary between each :ref:`basin<g_basin_reference-label>` and landfall location. The original assumption of a default :ref:`radius of maximum wind speed<g_rmw_reference-label>` of 87.6km is based off the Atlantic basin.

* **IBTrACS data is considered reliable for a limited number of years:** The data is only considered reliable from 1978 onwards for a number of :ref:`basins<g_basin_reference-label>`. This means there may not be enough data to get an accurate picture on the more infrequent :ref:`events<g_event_reference-label>` in the data such as category 5 storms. 

* **Circle exposure area may not be appropriate for all assets** For :ref:`exposure<g_exposure_reference-label>` areas that are long and thin (e.g., a long line of locations along a coastline), the circle approach may not be optimal. For these types of :ref:`exposures<g_exposure_reference-label>`, we may end up including a lot of extra area that is not relevant to the :ref:`assets<g_asset_reference-label>` we are aiming to cover. At present, only circles can be specified here to ensure the tool retains its simplicity.

* **Simulation Error:** 10,000 :ref:`simulations<g_simulation_reference-label>` may not be enough to reach a satisfactory level of :ref:`convergence<g_convergence_reference-label>`. This is especially true where higher category storms make up a large share of the cover's losses.



Assumptions and Limitations – Stochastic Sets
----------------------------------------------------------------

There are a number of limitations that should be considered when using this model. Bear in mind that this section is largely focused on the simulation method and data cleaning process:

* **Simulation Error:** 10,000 :ref:`simulations<g_simulation_reference-label>` may not be enough to reach a satisfactory level of :ref:`convergence<g_convergence_reference-label>`. This is especially true for more infrequent perils such as earthquake
* **Circle exposure area may not be appropriate for all assets:** For :ref:`exposure<g_exposure_reference-label>` areas that are long and thin (e.g., a long line of locations along a coastline), the circle approach may not be optimal. For these types of :ref:`exposures<g_exposure_reference-label>`, we may end up including a lot of extra area that is not relevant to the :ref:`assets<g_asset_reference-label>` we are aiming to cover. At present, only circles can be specified here to ensure the tool retains its simplicity.
* **Hazard data is only good as the methodology that went into producing it:** It is hard to determine for certain how accurate :ref:`stochastic<g_stochastic_reference-label>` hazard data is. There are likely to be limitations with any methods used in building the :ref:`event sets<g_eventset_reference-label>` presented here, especially at higher return periods where there is increasingly more uncertainty over the nature of losses. 
* **Older hazard data may be of limited relevance with a shifting climate:** Although :ref:`stochastic<g_stochastic_reference-label>` sets are not purely historical observations, historical data still factors into constructing :ref:`event sets<g_eventset_reference-label>` in a meaningful way. Given changing climate conditions, the expected magnitude/:ref:`frequency<g_frequency_reference-label>` of tropical cyclones could have increased or decreased over the reference period of historical data that fed into building these :ref:`stochastic<g_stochastic_reference-label>` sets.
