/**
 * Script for calculating and exporting Pasture Biomass 
 * from MapBiomas Collection 10 to Google Drive.
 */

// Define the output folder name in Google Drive
var driveFolder = 'MAPBIOMAS-PASTURE-BIOMASS';

// Define the versioning for the output
var outputVersion = 'c10';

// MapBiomas collection release ID
var collectionId = 10.0;

// Set theme metadata
var theme = { 'type': 'theme', 'name': 'PECUARIA-BIOMASSA' };

// Define the data source
var source = 'lapig';

// List of years to be processed
var years = [
    '2000', '2001', '2002', '2003', '2004',
    '2005', '2006', '2007', '2008',
    '2009', '2010', '2011', '2012',
    '2013', '2014', '2015', '2016',
    '2017', '2018', '2019', '2020',
    '2021', '2022', '2023', '2024'
];

// Define a bounding box geometry covering Brazil
var geometry = ee.Geometry.Polygon(
    [
        [
            [-75.46319738935682, 6.627809464162168],
            [-75.46319738935682, -34.62753178950752],
            [-32.92413488935683, -34.62753178950752],
            [-32.92413488935683, 6.627809464162168]
        ]
    ], null, false
);

// Iterate through each year
years.forEach(
    function (year) {
      
        // Load MapBiomas Collection 10 LULC
        var mapbiomas = ee.Image('projects/mapbiomas-public/assets/brazil/lulc/collection10/mapbiomas_brazil_collection10_integration_v2');

        // Extract the pasture mask (Class 15)
        var mapbiomas_pastagem = mapbiomas
          .select('classification_' + year)
          .eq(15)
          .selfMask();

        // Load GPP data and apply biomass conversion
        var gpp_grass_m = ee.ImageCollection("projects/global-pasture-watch/assets/ggpp-30m/v1/ugpp_m")
          .filter(ee.Filter.eq('system:index', year)).first()
          .multiply(0.01) // Conversion to tonnes C/ha/year
          .multiply(0.5)  // LUE factor
          .multiply(2.3)  // Above Ground Dry Biomass
          .updateMask(mapbiomas_pastagem);
          
        // Apply metadata
        var imageYear = gpp_grass_m
            .set(theme.type, theme.name)
            .set('collection', collectionId)
            .set('source', source)
            .set('version', outputVersion)
            .set('year', parseInt(year, 10));

        // Define visualization
        var vis = {
            'min': 10,
            'max': 25,
            'palette': ['f06b6e','f3b377','62ae56']
        };

        Map.addLayer(imageYear, vis, theme.name + ' ' + year, false);

        // Construct the output filename
        var fileName = 'mapbiomas_pasture_biomass_prod_c10_' + year;

        // Export the resulting image to Google Drive
        Export.image.toDrive({
            'image': imageYear,
            'description': fileName,
            'folder': driveFolder,
            'fileNamePrefix': fileName,
            'region': geometry,
            'scale': 30,
            'maxPixels': 1e13,
            'fileFormat': 'GeoTIFF',
            'formatOptions': {
                'cloudOptimized': true
            }
        });
    }
);
