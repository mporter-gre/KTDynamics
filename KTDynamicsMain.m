%KTDynamicsMain

%Detect spots and create tracks
[trackmateCenpA, modelCenpA, settingsCenpA, selectionModelCenpA, trackmateHec1, modelHec1, settingsHec1, selectionModelHec1] = KTTrack(session, imageId);

%Extract the spot coords and the track they are associated with
spotFeaturesCenpA = getSpotFeatures(modelCenpA);
spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, 10);

spotFeaturesHec1 = getSpotFeatures(modelHec1);
spotFeaturesForAnalysisHec1 = getLongTracks(spotFeaturesHec1, 10);

