function [trackmate, model, settings] = trackmateTracking(model, settings, imp)

settings.trackerFactory = fiji.plugin.trackmate.tracking.LAPTrackerFactory();
settings.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap(); % almost good enough
settings.trackerSettings.put('LINKING_MAX_DISTANCE', 0.2);
settings.trackerSettings.put('GAP_CLOSING_MAX_DISTANCE', 1);

trackmate = fiji.plugin.trackmate.TrackMate(model, settings);

ok = trackmate.checkInput();
if ~ok
    display(trackmate.getErrorMessage())
end
 
ok = trackmate.process();
if ~ok
    display(trackmate.getErrorMessage())
end

model = trackmate.getModel;
settings = trackmate.getSettings;

selectionModel = fiji.plugin.trackmate.SelectionModel(model);
% displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, imp);
% displayer.render()
% displayer.refresh()