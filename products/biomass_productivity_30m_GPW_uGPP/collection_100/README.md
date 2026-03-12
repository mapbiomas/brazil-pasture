![Vinícius Mesquita](lapig_logo_github.png)

# Pasture Aboveground Dry Biomass Productivity Mapping (MapBiomas Collection 10)

This repository contains the Google Earth Engine (GEE) implementation for calculating annual **Pasture Aboveground Dry Biomass** (tonnes Dry Matter (DM)/ha/year) across Brazil for the period 2000–2024.

The methodology integrates **MapBiomas Collection 10** land cover data with high-resolution [uncalibrated Gross Primary Productivity (uGPP)](https://developers.google.com/earth-engine/datasets/catalog/projects_global-pasture-watch_assets_ggpp-30m_v1_ugpp_m?hl=pt-br) datasets from the **Global Pasture Watch (GPW)** initiative.

---

## 1. Methodology Overview

The estimation of pasture biomass is based on a **Light Use Efficiency (LUE)** model. The **uGPP** (uncalibrated GPP) component provided by GPW represents the environmental and radiative components of the model without the application of a specific vegetation light-use efficiency constant ($\epsilon_{LUEmax}$).

### Core Productivity Formula

The final Gross Primary Productivity (GPP) is derived by the user-defined calibration of the $LUE_{max}$ parameter:

$$GPP = uGPP \times \epsilon_{LUEmax}$$

The **uGPP** component incorporates:

* **PAR (Photosynthetically Active Radiation):** 1° CERES radiation data.
* **fAPAR (Fraction of absorbed PAR):** Derived from Landsat archives.
* **Environmental Scalars:** Stress factors derived from 1-km MODIS temperature data.

> 
> **Calibration Flexibility:** The GPW baseline $LUE_{max}$ is set to $1~gC/m²/day/MJ$. This allows users to calibrate the GPP values according to specific regional conditions or land cover maps, as the uGPP data does not inherently include the $LUE_{max}$ application.
> 
> 

---

## 2. Dry Biomass Conversion (Collection 10)

For MapBiomas **Collection 10**, the annual uGPP carbon estimates ($gC/m²/year$) are converted into total annual **Aboveground Dry Biomass** ($t~DM/ha/year$) using parameters optimized for Brazilian cultivated pastures (*Brachiaria spp.*):

* **$\epsilon_{LUEmax}$ Factor (0.5):** The calibrated maximum light-use efficiency parameter applied to the uGPP baseline for Brazilian pasturelands.
* **Carbon-to-Biomass (2.3):** Conversion factor based on the assumption that carbon represents approximately **43%** of the total dry matter in common tropical grasses.
* **Unit Scaling ($10^{-2}$):** A factor of $0.01$ used to convert units from grams to tonnes and square meters to hectares.
* **Temporal Scale:** The script utilizes the **annual** aggregated uGPP values, which represent the accumulation of productivity over the full 365-day period.

---

## 3. Data Sources & Technical Specs

| Variable | Source | Resolution |
| --- | --- | --- |
| **Land Cover Mask** | MapBiomas Brazil Collection 10 (Class 15) | 30 m |
| **uGPP (Productivity)** | Global Pasture Watch (GPW) v1 | 30 m |

### Technical Considerations

* **Input Consistency:** While uGPP is provided at 30m, temperature (1km) and PAR (~111km) inputs are derived from coarser products, resampled to 30m using the cubic-spline method to ensure spatial continuity.
* **Annual Basis:** The data is delivered on an annual basis, providing a stable estimate of yearly productivity across the world.

---

## 4. Script Logic & Access

The script follows a direct conversion logic:

1. **Pasture Masking:** Isolates **Class 15** (Cultivated Pasture) from MapBiomas Collection 10 for each year.
2. **Biomass Calculation:** Multiplies the GPW `ugpp_m` image by the applied **0.5** ($\epsilon_{LUEmax}$), the **2.3** (Biomass conversion factor), and the **0.01** (Unit scaling factor).
3. **Export:** Results are generated as annual mosaics and exported as Cloud-Optimized GeoTIFFs (COG).

### Code Editor Link

**[Google Earth Engine Code Editor - Pasture Biomass](https://code.earthengine.google.com/57bac4c92ed2adc25a378c133eb83d55)**

---

## 5. Documentation & References

### Technical Document (ATBD)

* [Pasture Appendix ATBD - Collection 10 V2](https://brasil.mapbiomas.org/wp-content/uploads/sites/4/2026/01/Pasture-Appendix-ATBD-Collection-10-V2.pdf)

### Key Scientific Literature

* **Isik, M. S., et al. (2025).** *Light Use Efficiency (LUE) based bimonthly Gross Primary Productivity (GPP) for global grasslands at 30 m spatial resolution (2000-2022)*. PeerJ.
* **Ma, S. et al. (2018).** *Variations and determinants of carbon content in plants: a global synthesis*. Biogeosciences, [s. l.], vol. 15, no. 3, p. 693–702. DOI 10.5194/bg-15-693-2018.
* **Robinson, N. P., et al. (2018).** *Terrestrial primary production for the conterminous United States derived from Landsat 30 m and MODIS 250 m*. Remote Sensing in Ecology and Conservation.
* **Sanquetta, C. R., et al. (2022).** *Assessing the carbon stock of cultivated pastures in Rondônia, southwestern Brazilian Amazon*. Anais da Academia Brasileira de Ciências, [s. l.], vol. 94, no. 4. DOI 10.1590/0001-3765202220210262.
* **Veloso, G. A., et al. (2020).** *Modelling gross primary productivity in tropical savanna pasturelands for livestock intensification in Brazil*. Remote Sensing Applications: Society and Environment.
