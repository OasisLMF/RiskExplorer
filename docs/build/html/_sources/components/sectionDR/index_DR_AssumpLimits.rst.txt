Weather index - Assumptions and Limitations
==================================================

There are a number of limitations that should be considered when using this model.

* **CHIRPS is an accurate reflection of local precipitation:** Like all satellite-based rainfall datasets, CHIRPS is a proxy for actual precipitation. Its accuracy depends on the dominant rain forming processes, the number of rain gauges that are included in the final estimates and the quality of the calibration. As might be expected, the accuracy of satellite-based rainfall estimates varies from one region to another and so users are advised to carry out their own evaluations against local observations before deciding whether CHIRPS is a suitable dataset. These evaluations should assess the actual index that will be insured, as well as more general rainfall features, such as the seasonal cycle.

* **The payouts determined by CHIRPS reflect losses experienced:** A fundamental assumption of weather index insurance is that the selected index is a good proxy for losses experienced. Mismatch between losses and payouts is known as ‘basis risk’. Basis risk can be minimised by careful index design - including selecting an appropriate season and trigger threshold. Several of the exhibits included in the Risk Explorer are designed to help users assess basis risk:
  * exhibit 1 is a time series of payouts. Users can compare the time series against incidence of known droughts/low crop production
  * exhibit 2 shows the value of the index for user specified simulations and years. Users can compare good years against bad years to ensure that payouts are only triggered during bad years.

* **Older hazard data may be of limited relevance with a shifting climate:** Rainfall patterns are known to have shifted in many regions of the tropics over the simulation period (1983-2020), both as a result of climate change and natural variability. The amount of change varies from region to region, and also depends on the index design. Using a shorter period for the simulations would reduce this issue, but would lead to even greater errors when extrapolating return periods. Users are advised to look carefully at exhibit 1, in order to identify any large trends.

* **Return periods can be approximated by the observed occurrence of events:** It is highly challenging to estimate the occurrence of extreme events from relatively short time series of data. Unlike more sophisticated cat models, which utilise extreme value theory, the Risk Explorer simply estimates return period based on observe frequency. For this reason, the results for extreme events (i.e. less frequent than 1 in 10 years) should be treated with caution. Having said that, in practice most drought insurance schemes are targeted at 1:3 to 1:5 events

* **Exposure is not always adequately represented by randomly distributed insured households:** The simulation method used by the Risk Explorer allocates households randomly within the region of interest. In reality, people do not choose where to live randomly. Indeed, rural populations might be expected to gather in regions less severely affected by drought. The Risk Explorer mitigates this simplification in two ways:
  * In practice, the main variability in the simulations stems from year-to-year variability in precipitation, rather than from spatial variation. Running the simulations over a long period thus gives a reasonably accurate picture of the possible range of annual payouts
  * Both of the Risk Explorer indices target relative rather than absolute metrics of drought. Relative metrics tend to vary spatially far less than absolute metrics.

