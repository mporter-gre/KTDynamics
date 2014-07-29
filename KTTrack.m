function [trackmateCenpA, modelCenpA, settingsCenpA, selectionModelCenpA, trackmateHec1, modelHec1, settingsHec1, selectionModelHec1] = KTTrack(session, imageId)

Miji(true);

theImage = getImages(session, imageId);

cenpAStack = [];
for thisT = 1:10
    cenpAStack(:,:,end+1:end+13) = getStack(session, imageId, 0, thisT-1);
end
cenpAStack(:,:,1) = [];
cenpAStackSingle = single(cenpAStack);
cenpAImp = createImagePlusFromStack(cenpAStackSingle, theImage, 1, 13, 10);
[trackmateCenpA, modelCenpA, settingsCenpA, selectionModelCenpA] = trackMateExample(cenpAImp);


hec1Stack = [];
for thisT = 1:10
    hec1Stack(:,:,end+1:end+13) = getStack(session, imageId, 1, thisT-1);
end
theImage = getImages(session, imageId);
hec1Stack(:,:,1) = [];
hec1StackSingle = single(hec1Stack);
hec1Imp = createImagePlusFromStack(hec1StackSingle, theImage, 1, 13, 10);
[trackmateHec1, modelHec1, settingsHec1, selectionModelHec1] = trackMateExample(hec1Imp);

%MIJ.exit