![Vinícius Mesquita](lapig_logo_github.png)

# Brazilian Pasture Vigor Condition (CVP) Pipeline

This repository contains the high-performance processing chain used to generate the **Pasture Vigor Condition (CVP)** time series for Brazil (2000–2024). This workflow implements the methodologies described in the **[MapBiomas ATDB](https://brasil.mapbiomas.org/wp-content/uploads/sites/4/2026/01/Pasture-Appendix-ATBD-Collection-10-V2.pdf) for Collections 7, 8, 9, and 10**.

## 🛰 Methodology & Scientific Basis

Monitoring pasture vigor condition at a national scale requires a stable satellite signal that is resilient to cloud cover and seasonal variability.

### 1. Data Foundation

We utilize **MODIS MOD13Q1 (EVI)** data ($250m$ resolution) due to its superior radiometric stability and temporal frequency.

### 2. Signal Processing (TMWM + STL)

To extract the true underlying health of the pasture:

* **Gap-Filling (TMWM):** The raw EVI series is processed via the *Temporal Moving Window Medoid* algorithm to remove cloud artifacts and missing data.
* **De-seasonality (STL):** We apply *Seasonal-Trend decomposition using Loess*. This isolates the **Trend component**, effectively removing the seasonal "green-up" driven by rainfall, leaving only the structural vegetative vigor.



### 3. Recent Refinements (Collections 7–10)

Following the latest MapBiomas standards, this pipeline implements two critical updates:

* **Monthly Resolution:** Uses monthly data instead of bimonthly for better temporal precision.
* **Median Aggregation (50th Percentile):** We use the **median** (instead of the 90th percentile used in earlier collections) to produce a more conservative and inter-annually consistent estimate of pasture health.



## 🔬 Scientific Methodology

The technical foundation of this pipeline follows the analytical approach presented by [Santos et al. (2022)](https://www.mdpi.com/2072-4292/14/4/1024) in the article *"Assessing the Wall-to-Wall Spatial and Qualitative Dynamics of the Brazilian Pasturelands 2010–2018"*. This study established a high-resolution workflow for mapping pasture vigor condition across the entire Brazilian territory.

## 📂 Repository Structure

The core logic is divided into specialized scripts:

* **`run_vigor_condition.sh`**: Main orchestration script using `GDAL` and `GNU Parallel`.
* **`2_0_temporal_median_filter_parallel.py`**: Python implementation for temporal smoothing.
* **`6_normalization.py`**: Normalizes EVI values by Biome to account for regional edaphoclimatic conditions.
* **`mod13q1_stl-trend_tiles_col10.csv`**: Manifest of trend-decomposed MODIS tiles for download.

## 💻 Running on Windows (via WSL2)

Since this pipeline relies on Linux-native tools like `GNU Parallel`, Windows users should use **Windows Subsystem for Linux (WSL2)**.

### Installation Steps

1. **Install WSL2:** Open PowerShell as Administrator and run:
```powershell
wsl --install

```


*Restart your computer when finished.*
2. **Setup Linux:** Open the "Ubuntu" app and update the system:
```bash
sudo apt update && sudo apt upgrade -y

```


3. **Install Dependencies:**
```bash
sudo apt install gdal-bin python3-gdal parallel wget -y

```


4. **Access Windows Files:** Your Windows drives are located at `/mnt/c/` or `/mnt/d/`. Navigate to your project folder:
```bash
cd /mnt/c/Users/YourName/Documents/pasture_project
chmod +x run_vigor_condition.sh
./run_vigor_condition.sh

```



## 📂 Pipeline Stages

The `run_vigor_condition.sh` script automates the following stages:

| Stage | Process | Description |
| --- | --- | --- |
| **0** | **Raw Processing** | Merging trend tiles, reprojecting to EPSG:4326, and using LERC compression. 
| **1** | **Annual Mean** | Calculating the annual baseline from the 12 monthly trend components. 
| **2** | **Temporal Filter** | Applying a median filter to smooth inter-annual artifacts. 
| **3** | **Upsampling** | Matching the GPW mask resolution ($0.000269^\circ$). |
| **4** | **Pasture Mask** | Filtering results using the MapBiomas Pasture layer. 
| **5-7** | **Normalization** | Performing **Biome-specific normalization** (Step 6) to respect regional ecological baselines. 
| **8** | **CVP Classification** | Mapping the normalized trend into three vigor classes. 


## 📊 Classification Schema

| Class | Range (Norm EVI) | Condition |
| --- | --- | --- |
| **1** | $0.0 - 0.4$ | <br>** Low:** Persistent low productivity.
| **2** | $0.4 - 0.6$ | <br>** Medium:** Transitory condition or initial degradation.
| **3** | $0.6 - 1.0$ | <br>** High:** High vigor / optimal structural health.


## 🛠 Requirements

* **Linux/WSL2**
* **GDAL** ($> 3.0$ recommended)
* **GNU Parallel**
* **Python 3.x** (with `numpy` and `gdal` bindings)
