function [trackmate, model, settings, selectionModel] = trackMateExample(imp)

%----------------------------
% Create the model object now
%----------------------------
    
% Some of the parameters we configure below need to have
% a reference to the model at creation. So we create an
% empty model now.
model = fiji.plugin.trackmate.Model();
    
% Send all messages to ImageJ log window.
model.setLogger(fiji.plugin.trackmate.Logger.IJ_LOGGER)
       
%------------------------
% Prepare settings object
%------------------------
       
settings = fiji.plugin.trackmate.Settings();
settings.setFrom(imp)
       
% Configure detector - We use a java map
settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
map = java.util.HashMap();
map.put('DETECTOR_NAME', 'LOG_DETECTOR');
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', 0.25);
map.put('TARGET_CHANNEL', 1);
map.put('THRESHOLD', 25000); 
map.put('DO_MEDIAN_FILTERING', false);
settings.detectorSettings = map;
    
% Configure spot filters - Classical filter on quality
filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', 0.0, true);
settings.addSpotFilter(filter1)
     
%Configure tracker - We want to allow splits and fusions
settings.trackerFactory = fiji.plugin.trackmate.tracking.LAPTrackerFactory();
settings.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap(); % almost good enough
settings.trackerSettings.put('LINKING_MAX_DISTANCE', 1);
settings.trackerSettings.put('GAP_CLOSING_MAX_DISTANCE', 1);

%settings.trackerSettings.put('ALLOW_TRACK_SPLITTING', true);
%settings.trackerSettings.put('ALLOW_TRACK_MERGING', true);
    
% Configure track analyzers - Later on we want to filter out tracks 
% based on their displacement, so we need to state that we want 
% track displacement to be calculated. By default, out of the GUI, 
% not features are calculated. 
    
% The displacement feature is provided by the TrackDurationAnalyzer.
%settings.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer())
    
% Configure track filters - We want to get rid of the two immobile spots at 
% the bottom right of the image. Track displacement must be above 10 pixels.
%filter2 = fiji.plugin.trackmate.features.FeatureFilter('TRACK_DISPLACEMENT', 10.0, true);
%settings.addTrackFilter(filter2)
    
    
%-------------------
% Instantiate plugin
%-------------------
    
trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
       
%--------
% Process
%--------
    
ok = trackmate.checkInput();
if ~ok
    display(trackmate.getErrorMessage())
end
 
ok = trackmate.process();
if ~ok
    display(trackmate.getErrorMessage())
end
       
%----------------
% Display results
%----------------
     
selectionModel = fiji.plugin.trackmate.SelectionModel(model);
displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, imp);
displayer.render()
displayer.refresh()
    
% Echo results
display(model.toString())