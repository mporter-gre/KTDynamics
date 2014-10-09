function [trackmategreen, modelGreen, settingsGreen, numT] = trackGreen(session, imageId)

Miji(true);

theImage = getImages(session, imageId);
pixels = theImage.getPrimaryPixels;
numT = pixels.getSizeT.getValue;

greenIdx = getColourIdx(session, theImage, 'green');
redIdx = getColourIdx(session, theImage, 'red');

%Download the stack and create imageJ object
greenStack = [];
for thisT = 1:numT
    greenStack(:,:,end+1:end+13) = getStack(session, imageId, greenIdx, thisT-1);
end
greenStack(:,:,1) = [];
greenStackSingle = sqrt((single(greenStack)*2).^2);
greenImp = createImagePlusFromStack(greenStackSingle, theImage, 1, 13, numT);

%Optimise and perform tracking
[modelGreen, settingsGreen] = optimiseTrackMateGreen(greenImp, 500);
[trackmategreen, modelGreen, settingsGreen] = trackmateTracking(modelGreen, settingsGreen, greenImp);