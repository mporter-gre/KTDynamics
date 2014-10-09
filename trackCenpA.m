function [trackmateCenpA, modelCenpA, settingsCenpA, numT] = trackCenpA(session, imageId)

Miji(true);

theImage = getImages(session, imageId);
pixels = theImage.getPrimaryPixels;
numT = pixels.getSizeT.getValue;

greenIdx = getColourIdx(session, theImage, 'green');
redIdx = getColourIdx(session, theImage, 'red');

%Download the stack and create imageJ object
cenpAStack = [];
for thisT = 1:numT
    cenpAStack(:,:,end+1:end+13) = getStack(session, imageId, greenIdx, thisT-1);
end
cenpAStack(:,:,1) = [];
cenpAStackSingle = single(cenpAStack);
cenpAImp = createImagePlusFromStack(cenpAStackSingle, theImage, 1, 13, numT);

%Optimise and perform tracking
[modelCenpA, settingsCenpA] = optimiseTrackMate(cenpAImp, 500);
[trackmateCenpA, modelCenpA, settingsCenpA] = trackmateTracking(modelCenpA, settingsCenpA, cenpAImp);