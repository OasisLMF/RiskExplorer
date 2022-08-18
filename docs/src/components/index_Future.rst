What is going to be included in the model in the future?
============================================================

There are a number of extra features and functionality that will be built into the model throughout its development. Some of the key future improvements to highlight here are:

**Exposure**

* **Allow for exposure upload beyond simple location/area:** Ability for users to upload multiple assets with financial information in the tool.

* **Exposure Analysis Functionality:** As :ref:`exposure<g_exposure_reference-label>` information becomes more detailed, ability for users to break down their assets by typology, category replacement cost and other factors.

**Hazard**

* **Years of Selection:** Ability to vary the timeframe of historical data that feeds the tool. E.g., if the user feels there is a climate impact and would be comfortable using a more recent window, they could select a subset of the available track data, such as the most recent 15 years.

* **Greater Peril Coverage:** Additional :ref:`perils<g_peril_reference-label>` to be included such as flood, wildfire, earthquake and convective storm.

* **Greater Data Source Coverage:** Additional data sources beyond :ref:`IBTrACS<g_ibtracs_reference-label>` e.g., :ref:`Oasis<g_oasis_reference-label>` :ref:`stochastic<g_stochastic_reference-label>` :ref:`event sets<g_eventset_reference-label>`.

* **Hazard Data Upload Functionality:** Ability to upload custom :ref:`stochastic<g_stochastic_reference-label>` :ref:`event sets<g_eventset_reference-label>` directly into the tool.

**Vulnerability**

* **Ability to handle more types of insurance covers beyond simple parametric:** Specifically non-typical humanitarian based covers e.g., with number of people affected triggers.

* **Vulnerability Upload Functionality:** Ability to upload custom :ref:`vulnerability<g_vulnerability_reference-label>` functions directly into the tool.

**Simulation**

* **Ability to handle different calculation methods beyond existing historical sampling simulation method:** Different simulation methods will be required to handle :ref:`stochastic<g_stochastic_reference-label>` :ref:`event sets<g_eventset_reference-label>` as well as additional :ref:`perils<g_peril_reference-label>` where the historical sampling method may not be appropriate.

* **Methodological improvements to the simulation method** including better accounting for land decay and variable :ref:`RMW<g_rmw_reference-label>` by :ref:`basin<g_basin_reference-label>`.

* **Optimise speed of calculation engine:** Ensure large number of :ref:`simulations<g_simulation_reference-label>` can be easily run.

**Outputs**

* **Build on range of outputs currently available:**  As sophistication of inputs increases, an increased and more detailed number of outputs will be generated.

* **Dynamic Cover Analysis:**  Make it easier to tweak cover design directly in the output tab and directly see the impact on :ref:`expected payouts<g_expectedpayout_reference-label>` across the curve.

**UI**

* **More sophisticated user feedback:** E.g., hover-over tooltips and direct links to appropriate help sections on each page.
