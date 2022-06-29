Assumptions and Limitations
--------------------------------

There are a number of limitations that should be considered when using this model. Bear in mind that this section is largely focused on the simulation method and data cleaning process:

* **Sampling method does not handle inland decay well:** If an exposure is located near a large inland area, the model may understate the likelihood of payouts. This is because tropical cyclones tend to decay as they move inland and lose their main source of fuel. Any samples taken over land will likely see lower storm activity, so if these contribute significantly to the expected loss, the average payout may be understated. The weighting function will correct for this to some degree as more inland areas are likely to be further away, but this does not completely resolve the issue. 

* **Older hazard data may be of limited relevance with a shifting climate:** Given changing climate conditions, the expected magnitude/frequency of tropical cyclones could have increased or decreased in a given basin over the hazard data's recording period. There is a risk that the inclusion of some of the earlier data-years in our simulation approach may lead to us understating or overstating the expected loss as they reflect fundamentally different cyclone formation conditions. This is a particular issue for the North Atlantic basin where data goes back to 1948, over 70 years ago. 

* **Linear interpolation of tracks is likely to be inaccurate:** Cubic spline is a more appropriate method for interpolating these tracks and matches the scientific data better. Linear interpolation is easier to calculate but the cubic spline adjustment will be looked into for further releases. 

* **Inconsistencies in max wind speed measurements between agencies:** Different measurement periods of max wind speeds are used by each agency. As such, it may be misleading to compare output from one agency's data to another. To give an example, RSMC Tokyo record 10 min maximum wind speeds whereas US agencies use 1 minute maximum wind speeds. As such we'd typically expect to see higher losses using the US data set as maximum wind speeds do not need to be sustained for as long (assuming there are no major underlying differences in data collection aside from this). It's also worth noting that the time interval for the maximum wind speed is not specified in the vulnerability section, so implicitly we are assuming the same time interval as the agency who's data we are using.

* **Some exposures are impacted by multiple cyclone basins:** The tool currently only allows for one basin to be modelled at a time, but in practice certain areas can be impacted by storms from multiple basins. This is particularly an issue for Central America.

* **Weighting function:** An exponential weighting function is used here with parameterisation selected using expert judgement. There are likely a range of "reasonable" weighting functions that could be applied and there is ultimately no way of knowing whether the weighting function selected is indeed the most appropriate one.

* **Assumption of radius of maximum wind speed is constant by basin and landfall location:** In reality this will vary between each basin and landfall location. The original assumption of a default radius of maximum wind speeds of 75km is largely based off the Atlantic and Pacific basins.

* **IBTrACS data is over a limited number of years:** The data is only considered reliable from 1978 and beyond for a number of basins. This means there may not be enough data to get an accurate picture on the more extreme events such as category 5 storms. 

* **Simulation Error:** 10,000 simulations may not be enough to reach a satisfactory level of convergence. This is especially true where higher category storms make up a large share of the cover's losses.

