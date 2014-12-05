function [model, settings] = optimiseTrackMateGreen(imp, maxSpots)

thresh = 11200; %7800 %12700 %30000

model = fiji.plugin.trackmate.Model();
model.setLogger(fiji.plugin.trackmate.Logger.IJ_LOGGER)
settings = fiji.plugin.trackmate.Settings();
settings.setFrom(imp);
settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
map = java.util.HashMap();
map.put('DETECTOR_NAME', 'LOG_DETECTOR');
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', 0.25);
map.put('TARGET_CHANNEL', 1);
map.put('THRESHOLD', thresh);
map.put('DO_MEDIAN_FILTERING', false);
settings.detectorSettings = map;
filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', 0.0, true);
settings.addSpotFilter(filter1);
trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
ok = trackmate.checkInput();
display(trackmate.getErrorMessage())
ready = 0;
while ready == 0
    try
        ok = trackmate.process();
    catch
    end
    spotFeatures = getSpotFeatures(model);
    numSpots = length(spotFeatures);
    if numSpots < maxSpots
        ready = 1;
        thresh
        model  = trackmate.getModel;
        settings = trackmate.getSettings;
    else
        thresh = thresh * floor(numSpots/maxSpots)/2;
        map.put('THRESHOLD', thresh);
        settings.detectorSettings = map;
        trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
    end
end
