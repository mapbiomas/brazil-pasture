![Vinícius Mesquita](source/lapig_logo_github.png)
<div>
    <h1> MAPBIOMAS BRAZIL – PASTURE </h1>
</div>

Developed by the [Remote Sensing and GIS Lab (LAPIG)](https://lapig.iesa.ufg.br/)

---

## About

This repository contains scripts and resources for the mapping of pasturelands in the **Brazil**, as part of the MapBiomas Brazil initiative. The mapping is based on multi-temporal remote sensing imagery from the **Landsat (30m)** and **Sentinel (10m)** satellite programs.

The classification processes include data preparation, model training, classification, and a series of post-processing routines to ensure temporal and spatial consistency of the maps.

For detailed methodology and technical specifications, refer to the Pasture Appendix of the [Algorithm Theoretical Basis Document (ATBD)](https://mapbiomas.org/download-dos-atbds).

---

## Repository Structure

The repository is organized into subfolders by image source and processing resolution, following the MapBiomas classification workflow for the pasturelands:

- [`lulc_30m_landsat`](https://github.com/mapbiomas/brazil-pasture/tree/main/lulc_30m_landsat%20):  
  Scripts for generating annual LULC maps at **30-meter resolution**, using Landsat imagery.

- [`lulc_10m_sentinel`](https://github.com/mapbiomas/brazil-pasture/tree/main/lulc_10m_sentinel):  
  Scripts for generating annual LULC maps at **10-meter resolution**, using Sentinel-2 imagery.

- [`product_pasture_vigor_condition_30m_MOD13Q1_EVI`](https://github.com/mapbiomas/brazil-pasture/tree/main/pasture_vigor_condition_30m_mod13q1_evi):  
  Scripts for generating Pasture Vigor Condition product at **30-meter resolution**, using MOD13Q1 EVI and LULC 30m pasture maps.
  
- [`product_pasture_biomass_productivity_30m_GPW_uGPP`](https://github.com/mapbiomas/brazil-pasture/tree/main/pasture_biomass_productivity_30m_gpw_ugpp):  
  Scripts for generating Pasture Biomass Productivity product at **30-meter resolution**, using GPW uncalibrated Gross Primary Productivity (uGPP) and LULC 30m pasture maps.

Each subfolder includes a step-by-step processing chain with processing/classification scripts, filtering procedures, and additional assets used in the generation of MapBiomas Pasture LULC collections and products.

---

## Citation

If you use any part of this repository or the resulting data in your work, please cite MapBiomas and LAPIG accordingly. For official data access and citation guidelines, visit the [MapBiomas Terms of Use](https://brasil.mapbiomas.org/termos-de-uso/). The MapBiomas data are public, open and free under Creative Commons CC-BY license.

---

## Contact

For questions, suggestions, or to report issues, please contact:

- [vinicius.mesquita@ufg.br](mailto:vinicius.mesquita@ufg.br)  
- [contato@mapbiomas.org](mailto:contato@mapbiomas.org)
