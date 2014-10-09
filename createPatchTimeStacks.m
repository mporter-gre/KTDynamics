function [impTiles, coords, tileStack, tileStackCenpA] = createPatchTimeStacks(session, imageId, spotFeatures, numT)

[store, pixels] = getRawPixelsStore(session, imageId);

sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
numZ = pixels.getSizeZ.getValue;

theImage = getImages(session, imageId);
Miji(true);
numTracks = length(unique([spotFeatures(:).trackId]));
counter = 1;

%Get the coordinates of the patches to extract
for thisTrack = 1:numTracks
    coords{thisTrack}(:,1) = int16(([spotFeatures(counter:counter+numT-1).x])); % ./ 0.04)-4);
    coords{thisTrack}(:,2) = int16(([spotFeatures(counter:counter+numT-1).y])); % ./ 0.04)-4);
    coords{thisTrack}(:,3) = int16(([spotFeatures(counter:counter+numT-1).z])); % ./ 0.125)-3);
    
    %Keep this section indexed from 1
    for thisT = 1:numT
        if coords{thisTrack}(thisT,1) < 1
            coords{thisTrack}(thisT,1) = 1;
        end
        if coords{thisTrack}(thisT,2) < 1
            coords{thisTrack}(thisT,2) = 1;
        end
        if coords{thisTrack}(thisT,3) < 1
            coords{thisTrack}(thisT,3) = 1;
        end
        if coords{thisTrack}(thisT,1) > sizeX - 8
            coords{thisTrack}(thisT,1) = sizeX - 8;
        end
        if coords{thisTrack}(thisT,2) > sizeY - 8
            coords{thisTrack}(thisT,2) = sizeY - 8;
        end
        if coords{thisTrack}(thisT,3) > numZ - 5
            coords{thisTrack}(thisT,3) = numZ - 5;
        end
        
        %Get the tiles, change index from 0
        for thisZ = 1:5
            tileStack{thisTrack}{thisT}(:,:,thisZ) = getTile(pixels, store, coords{thisTrack}(thisT,3)+thisZ-1, 1, thisT-1, coords{thisTrack}(thisT,1)-1, coords{thisTrack}(thisT,2)-1, 9, 9);
            tileStackCenpA{thisTrack}{thisT}(:,:,thisZ) = getTile(pixels, store, coords{thisTrack}(thisT,3)+thisZ-1, 0, thisT-1, coords{thisTrack}(thisT,1)-1, coords{thisTrack}(thisT,2)-1, 9, 9);
        end
        impTiles{thisTrack}{thisT} = createImagePlusFromPatch(single(tileStack{thisTrack}{thisT}), theImage, 1, 5, 1);
    end
    %impTiles{thisTrack} = createImagePlusFromPatch(single(tileStack), theImage, 1, 5, numT);

    counter = counter + numT;
    
end
store.close

