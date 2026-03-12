#!/bin/bash

# ==============================================================================
# PASTURE VIGOR CONDITION (CVP) PIPELINE 
# Data: MOD13Q1 EVI Trend Component (Gap-filled & STL Decomposed)
# Geography: Brazil (Biomes) | Period: 2000-2024
# ==============================================================================

### PRE-PROCESSING: DATA ACQUISITION
cat mod13q1_stl-trend_tiles_col10.csv > urls.txt
parallel -j 20 wget -q {} :::: urls.txt

# ------------------------------------------------------------------------------
# 0 - RAW DATA PROCESSING AND MERGING
# ------------------------------------------------------------------------------
mkdir -p 0_RAW/BASE 0_RAW/REPROJECT_WGS84

# Build Virtual Rasters (VRT) for each month/year from the trend tiles
parallel --jobs 20 "gdalbuildvrt 0_RAW/BASE/veg_evi_mod13q1_{1}.{2}.vrt \
    0_RAW/s3.opengeohub.org/tmp-mod13q1.061-tif/tiled_data/**/*_{1}.{2}.01..{1}.{2}.{3}_*.tif \
    -srcnodata -3000 -vrtnodata -3000" \
    ::: {2000..2024} ::: 01 02 03 04 05 06 07 08 09 10 11 12 \
    ::: 31 28 31 30 31 30 31 31 30 31 30 31

# Convert VRT to TIF (EPSG:3857) using high-precision LERC compression for trend values
parallel --jobs 4 "gdal_translate 0_RAW/BASE/veg_evi_mod13q1_{1}.{2}.vrt \
    0_RAW/BASE/veg_evi_mod13q1_{1}.{2}_epsg_3857.tif \
    -co COMPRESS=LERC_ZSTD -co MAX_Z_ERROR=1.0 -co PREDICTOR=2 \
    -co TILED=YES -co BIGTIFF=YES -co NUM_THREADS=ALL_CPUS" \
    ::: {2000..2024} ::: 01 02 03 04 05 06 07 08 09 10 11 12

# Reproject to WGS84 (EPSG:4326)
parallel --jobs 8 "gdalwarp 0_RAW/BASE/veg_evi_mod13q1_{1}.{2}_epsg_3857.tif \
    0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.{2}.tif \
    -overwrite -t_srs 'EPSG:4326' -co COMPRESS=LERC_ZSTD -co MAX_Z_ERROR=1.0 \
    -co PREDICTOR=2 -co TILED=YES -co BIGTIFF=YES -co NUM_THREADS=ALL_CPUS" \
    ::: {2000..2024} ::: 01 02 03 04 05 06 07 08 09 10 11 12

# ------------------------------------------------------------------------------
# 1 - ANNUAL TREND MEAN CALCULATION
# ------------------------------------------------------------------------------
mkdir -p 1_MEAN

# Calculate the annual mean of the monthly trend components
parallel --jobs 10 "gdal_calc.py \
    -A 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.01.tif \
    -B 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.02.tif \
    -C 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.03.tif \
    -D 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.04.tif \
    -E 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.05.tif \
    -F 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.06.tif \
    -G 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.07.tif \
    -H 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.08.tif \
    -I 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.09.tif \
    -J 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.10.tif \
    -K 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.11.tif \
    -L 0_RAW/REPROJECT_WGS84/veg_evi_mod13q1_{1}.12.tif \
    --outfile='1_MEAN/veg_evi_mod13q1_{1}_avg.tif' --calc='numpy.average([A,B,C,D,E,F,G,H,I,J,K,L], axis=0)' \
    --NoDataValue=-3000 --co='COMPRESS=LZW' --co='BIGTIFF=YES' --co='TILED=YES'" ::: {2000..2024}

# ------------------------------------------------------------------------------
# 2 - TEMPORAL MEDIAN FILTERING
# ------------------------------------------------------------------------------
mkdir -p 2_FILTERED
python 2_0_temporal_median_filter_parallel.py 1_MEAN 2_FILTERED

# Assemble and convert filtered trend results
parallel --jobs 10 "gdalbuildvrt 2_FILTERED/veg_evi_mod13q1_{1}_avg.vrt 2_FILTERED/veg_evi_mod13q1_{1}_avg/*.tif -srcnodata -3000 -vrtnodata -3000" ::: {2000..2024}
parallel --jobs 4 "gdal_translate 2_FILTERED/veg_evi_mod13q1_{1}_avg.vrt 2_FILTERED/veg_evi_mod13q1_{1}_avg.tif \
    -co COMPRESS=LERC_ZSTD -co MAX_Z_ERROR=1.0 -co PREDICTOR=2 -co TILED=YES -co BIGTIFF=YES -co NUM_THREADS=ALL_CPUS" ::: {2000..2024}

# ------------------------------------------------------------------------------
# 3 - UPSAMPLING (Matching MapBiomas Mask)
# ------------------------------------------------------------------------------
mkdir -p 3_FILTERED_UPSAMPLIG
parallel --jobs 10 "gdalbuildvrt 3_FILTERED_UPSAMPLIG/veg_evi_mod13q1_{1}_avg_filtered.vrt 2_FILTERED/veg_evi_mod13q1_{1}_avg.tif \
    -tr 0.000269494585236 0.000269494585236 -te -78.0030517 -36.0074410 -29.9969033 8.0039892" ::: {2000..2024}
parallel --jobs 6 "gdal_translate 3_FILTERED_UPSAMPLIG/veg_evi_mod13q1_{1}_avg_filtered.vrt 3_FILTERED_UPSAMPLIG/veg_evi_mod13q1_{1}_avg_filtered_res.tif \
    -co COMPRESS=LERC_ZSTD -co MAX_Z_ERROR=1.0 -co PREDICTOR=2 -co TILED=YES -co BIGTIFF=YES -co NUM_THREADS=ALL_CPUS" ::: {2000..2024}

# ------------------------------------------------------------------------------
# 4 - PASTURE MASKING (Using MapBiomas)
# ------------------------------------------------------------------------------
mkdir -p 4_CROP_PASTURE
parallel --jobs 6 "gdal_calc.py -A 3_FILTERED_UPSAMPLIG/veg_evi_mod13q1_{1}_avg_filtered_res.tif -B PASTURE_MASK/mapbiomas-collection10-pastagem-{1}.tif \
    --outfile='4_CROP_PASTURE/pasture_evi_Y{1}_AVG_fill.tif' --calc='((B==1) & (A !=-3000))*A + ((B==0) | (A ==-3000))*-3000' \
    --overwrite --NoDataValue=-3000 --co='COMPRESS=LZW' --co='BIGTIFF=YES' --co='TILED=YES'" ::: {2000..2024}

# ------------------------------------------------------------------------------
# 5 - REGION CROPPING (By Biome)
# ------------------------------------------------------------------------------
mkdir -p 5_CROP_BIOME/{AMAZONIA,CAATINGA,CERRADO,MATA_ATLANTICA,PANTANAL}
parallel --jobs 5 "gdalwarp -overwrite -multi -wo NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 20000 -srcnodata -3000 -dstnodata -3000 \
    -cutline SHP/{2}.shp -crop_to_cutline 4_CROP_PASTURE/pasture_evi_Y{1}_AVG_fill.tif 5_CROP_BIOME/{2}/pasture_evi_Y{1}_AVG_fill_MAPBIOMAS_{2}.tif \
    -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=YES" ::: {2000..2024} ::: AMAZONIA CAATINGA CERRADO MATA_ATLANTICA PANTANAL

# ------------------------------------------------------------------------------
# 6 - TREND NORMALIZATION
# ------------------------------------------------------------------------------
mkdir -p 6_NORMALIZATION/BIOMAS/{AMAZONIA,CAATINGA,CERRADO,MATA_ATLANTICA,PANTANAL}
parallel --jobs 3 "python 6_normalization.py 5_CROP_BIOME/{1} 6_NORMALIZATION/BIOMAS/{1} -3000" ::: AMAZONIA CAATINGA CERRADO MATA_ATLANTICA PANTANAL

# ------------------------------------------------------------------------------
# 7 - REGION MERGING (Normalized Trend)
# ------------------------------------------------------------------------------
mkdir -p 7_BIOME_MERGE
parallel --jobs 12 "gdalbuildvrt 7_BIOME_MERGE/pasture_evi_Y{1}_AVG_fill_MAPBIOMAS_NORM.vrt -vrtnodata nan -srcnodata nan 6_NORMALIZATION/BIOMAS/*/pasture_evi_Y{1}_AVG_fill_MAPBIOMAS_*.tif" ::: {2000..2024}
parallel --jobs 10 "gdal_translate 7_BIOME_MERGE/pasture_evi_Y{1}_AVG_fill_MAPBIOMAS_NORM.vrt 7_BIOME_MERGE/pasture_evi_Y{1}_AVG_fill_MAPBIOMAS_NORM.tif -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=YES" ::: {2000..2024}

# ------------------------------------------------------------------------------
# 8 - CVP ESTIMATES (Condition of Vegetated Pasture Classification)
# ------------------------------------------------------------------------------
mkdir -p 8_CVP
# Classifies Trend into: 1 (Low/Degraded), 2 (Medium/Stable), 3 (High/Productive)
parallel --jobs 10 "gdal_calc.py -A 7_BIOME_MERGE/pasture_evi_Y{1}_AVG_fill_MAPBIOMAS_NORM.tif --type=Byte \
    --outfile='8_CVP/cvp_pasture_br_Y{1}.tif' --calc='((A >= 0) & (A < 0.4))*1 + ((A >= 0.4) & (A < 0.6))*2 + ((A >= 0.6) & (A <= 1))*3' \
    --NoDataValue=0 --co='COMPRESS=LZW' --co='BIGTIFF=YES' --co='TILED=YES' --overwrite" ::: {2000..2024}

# Generate overviews for fast visualization
parallel --jobs 6 "gdaladdo 8_CVP/cvp_pasture_br_Y{1}.tif 2 4 8" ::: {2000..2024}
