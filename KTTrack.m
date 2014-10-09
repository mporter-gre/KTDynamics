function [trackmateCenpA, modelCenpA, settingsCenpA, trackmateHec1, modelHec1, settingsHec1, numT] = KTTrack(session, imageId)

Miji(true);

theImage = getImages(session, imageId);
pixels = theImage.getPrimaryPixels;
numT = pixels.getSizeT.getValue;

greenIdx = getColourIdx(session, theImage, 'green');
redIdx = getColourIdx(session, theImage, 'red');

cenpAStack = [];
for thisT = 1:numT
    cenpAStack(:,:,end+1:end+13) = getStack(session, imageId, greenIdx, thisT-1);
end
cenpAStack(:,:,1) = [];
cenpAStackSingle = single(cenpAStack);
cenpAImp = createImagePlusFromStack(cenpAStackSingle, theImage, 1, 13, numT);

%[trackmateCenpA, modelCenpA, settingsCenpA, selectionModelCenpA] = trackMateExample(cenpAImp);
[modelCenpA, settingsCenpA] = optimiseTrackMate(cenpAImp);
[trackmateCenpA, modelCenpA, settingsCenpA] = trackmateTracking(modelCenpA, settingsCenpA, cenpAImp);

spotFeaturesCenpA = getSpotFeatures(modelCenpA);
spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, numT);




hec1Stack = [];
for thisT = 1:numT
    hec1Stack(:,:,end+1:end+13) = getStack(session, imageId, redIdx, thisT-1);
end
theImage = getImages(session, imageId);
hec1Stack(:,:,1) = [];
hec1StackSingle = single(hec1Stack);





% hec1Imp = createImagePlusFromStack(hec1StackSingle, theImage, 1, 13, numT);
% %[trackmateHec1, modelHec1, settingsHec1, selectionModelHec1] = trackMateExample(hec1Imp);
% [modelHec1, settingsHec1] = optimiseTrackMate(hec1Imp);
% trackmateHec1 = trackmateTracking(modelHec1, settingsHec1, hec1Imp);

%MIJ.exit