# Pasture Dry Biomass Productivity Mapping (MapBiomas Collection 10)

This repository contains the Google Earth Engine (GEE) implementation for calculating annual **Pasture Dry Biomass** (tonnes/ha/year) across Brazil for the period 2000–2024. The methodology integrates **MapBiomas Collection 10** land cover data with high-resolution productivity datasets from the **Global Pasture Watch (GPW)** consortium.

---

## 1. Methodology Overview

The estimation of pasture biomass is based on a **Light Use Efficiency (LUE)** model, which relates productivity to the amount of energy absorbed from solar radiation.

### Core Productivity Formula

The uncalibrated Gross Primary Productivity (uGPP) is calculated as:


$$GPP = PAR \times fAPAR \times \epsilon_{LUE}$$

* **PAR (Photosynthetically Active Radiation):** Calculated from short-wave radiation (CERES SYN1deg), representing the energy available for plants to use.
* **fAPAR (Fraction of absorbed PAR):** Determined by its relation to NDVI values, representing the fraction of PAR absorbed by the canopy.
* **LUE ($\epsilon$):** The efficiency coefficient, adjusted by environmental constraints like temperature ($T_{scalar}$) and water availability ($W_{scalar}$).

---

## 2. Dry Biomass Conversion (Collection 10)

To convert GPP carbon estimates ($gC/m^2/day$) into total Dry Biomass ($tonnes/ha/year$), the script applies a specific conversion workflow optimized for **Collection 10**:

* **LUE Factor (0.5):** A standard light-use efficiency parameter recommended for cultivated pasturelands in Brazil, specifically *Brachiaria spp*.
* **Carbon-to-Biomass (2.3):** Based on updated literature (Ma et al., 2018; Sanquetta et al., 2022), assuming carbon represents approximately **43%** of the total dry biomass in common Brazilian grasses.
* **Unit Scaling ($10^{-2}$):** A simplified factor ($0.01$) to handle the conversion from grams to tonnes and square meters to hectares.
* **Temporal Accumulation:** The annual uGPP data is delivered by considering the average of six bimonthly observations accumulated along 365 days.

---

## 3. Data Sources

| Variable | Source | Resolution |
| --- | --- | --- |
| **Land Cover Mask** | MapBiomas Brazil Collection 10 (Class 15) | 30 m |
| **uGPP (Productivity)** | Global Pasture Watch (GPW) v1 (`ugpp_m`) | 30 m |

---

## 4. Script Logic & Access

1. **Pasture Masking:** For each year in the processing loop, the script selects the MapBiomas integrated map and isolates **Class 15** (Cultivated Pasture).
2. **Biomass Calculation:** The GPW `ugpp_m` image is multiplied by the specific conversion factors (0.5 for LUE, 2.3 for biomass, and 0.01 for unit scaling).
3. **Metadata Assignment:** Each image is tagged with the collection ID (10.0), source (LAPIG), version, and year.
4. **Export:** Results are exported as **Cloud-Optimized GeoTIFFs (COG)** directly to Google Drive.

### Code Editor Link

You can access and run the full processing script here:
**[Google Earth Engine Code Editor - Pasture Biomass](https://code.earthengine.google.com/57bac4c92ed2adc25a378c133eb83d55)**

---

## 5. Documentation & References

### Technical Document (ATBD)

For in-depth details regarding algorithms, unit conversions, and calibration for Brazilian pasturelands, see the official appendix:

* [Pasture Appendix ATBD - Collection 10 V2](https://brasil.mapbiomas.org/wp-content/uploads/sites/4/2026/01/Pasture-Appendix-ATBD-Collection-10-V2.pdf)

### Scientific Literature

* **Isik, M. S., et al. (2025).** *Light Use Efficiency (LUE) based bimonthly Gross Primary Productivity (GPP) for global grasslands at 30 m spatial resolution (2000-2022)*. PeerJ.
* **Veloso, G. A., et al. (2020).** *Modelling gross primary productivity in tropical savanna pasturelands for livestock intensification in Brazil*. Remote Sensing Applications: Society and Environment.
* **Robinson, N. P., et al. (2018).** *Terrestrial primary production for the conterminous United States derived from Landsat 30 m and MODIS 250 m*. Remote Sensing in Ecology and Conservation.
* **Sanquetta, C. R., et al. (2022).** *Assessing the carbon stock of cultivated pastures in Rondônia, southwestern Brazilian Amazon*. Anais da Academia Brasileira de Ciências, [s. l.], vol. 94, no. 4. DOI 10.1590/0001-3765202220210262.
*  **Ma, S. et al. (2018).** *Variations and determinants of carbon content in plants: a global synthesis*. Biogeosciences, [s. l.], vol. 15, no. 3, p. 693–702. DOI 10.5194/bg-15-693-2018. 

---

**Next Step:** Would you like me to help you generate a README file specifically for a GitHub repository using this content?
