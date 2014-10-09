function [trackmateRed, modelRed, settingsRed, numT] = trackRed(session, imageId)

Miji(true);

theImage = getImages(session, imageId);
pixels = theImage.getPrimaryPixels;
numT = pixels.getSizeT.getValue;

greenIdx = getColourIdx(session, theImage, 'green');
redIdx = getColourIdx(session, theImage, 'red');

%Download the stack and create imageJ object
redStack = [];
for thisT = 1:numT
    redStack(:,:,end+1:end+13) = getStack(session, imageId, redIdx, thisT-1);
end
redStack(:,:,1) = [];
redStackSingle = sqrt((single(redStack)*3).^2);
redImp = createImagePlusFromStack(redStackSingle, theImage, 1, 13, numT);

%Optimise and perform tracking
[modelRed, settingsRed] = optimiseTrackMateRed(redImp, 500);
[trackmateRed, modelRed, settingsRed] = trackmateTracking(modelRed, settingsRed, redImp);