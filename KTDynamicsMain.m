%KTDynamicsMain

%get the cenpA tracks...
[trackmateCenpA, modelCenpA, settingsCenpA, numT] = trackGreen(session, imageId);

%Extract the spots and filter for full-length tracks
spotFeaturesCenpA = getSpotFeatures(modelCenpA);
spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, numT);
numSpots = length(spotFeaturesForAnalysisCenpA);
trackCounter = 1;
thisTrack = 1;
for thisSpot = 1:numSpots
    tracksCenpA{thisTrack}(trackCounter,:) = [spotFeaturesForAnalysisCenpA(thisSpot).x, spotFeaturesForAnalysisCenpA(thisSpot).y, spotFeaturesForAnalysisCenpA(thisSpot).z, spotFeaturesForAnalysisCenpA(thisSpot).t];
    if trackCounter == numT
        thisTrack = thisTrack + 1;
        trackCounter = 1;
    else
        trackCounter = trackCounter + 1;
    end
end

%get the cenpA tracks...
[trackmateHec1, modelHec1, settingsHec1, numT] = trackRed(session, imageId);

%Extract the spots and filter for full-length tracks
spotFeaturesHec1 = getSpotFeatures(modelHec1);
spotFeaturesForAnalysisHec1 = getLongTracks(spotFeaturesHec1, numT);

numSpots = length(spotFeaturesForAnalysisHec1);
trackCounter = 1;
thisTrack = 1;
for thisSpot = 1:numSpots
    tracksHec1{thisTrack}(trackCounter,:) = [spotFeaturesForAnalysisHec1(thisSpot).x, spotFeaturesForAnalysisHec1(thisSpot).y, spotFeaturesForAnalysisHec1(thisSpot).z, spotFeaturesForAnalysisHec1(thisSpot).t];
    if trackCounter == numT
        thisTrack = thisTrack + 1;
        trackCounter = 1;
    else
        trackCounter = trackCounter + 1;
    end
end


%Compare the Hec1 and CenpA tracks, try to pair them up...
numHec1Tracks = length(tracksHec1);
for thisHec1 = 1:numHec1Tracks
    tracksHec1um{thisHec1}(:,1) = tracksHec1{thisHec1}(:,1);%.*0.04;
    tracksHec1um{thisHec1}(:,2) = tracksHec1{thisHec1}(:,2);%.*0.04;
    tracksHec1um{thisHec1}(:,3) = tracksHec1{thisHec1}(:,3);%.*0.125;
end
numCenpATracks = length(tracksCenpA);
for thisCenpA = 1:numCenpATracks
    tracksCenpAum{thisCenpA}(:,1) = tracksCenpA{thisCenpA}(:,1);%.*0.04;
    tracksCenpAum{thisCenpA}(:,2) = tracksCenpA{thisCenpA}(:,2);%.*0.04;
    tracksCenpAum{thisCenpA}(:,3) = tracksCenpA{thisCenpA}(:,3);%.*0.125;
end
%Get the distance between each Hec1 and CenpA track at each time point
for thisHec1 = 1:numHec1Tracks
    for thisCenpA = 1:numCenpATracks
        for thisT = 1:numT
            distum{thisHec1}(thisT, thisCenpA) = pdist2(tracksHec1um{thisHec1}(thisT,:), tracksCenpAum{thisCenpA}(thisT,:));
        end
    end
end
%Get the minimum mean distance between the two sets of tracks
for thisHec1 = 1:numHec1Tracks
    meanDistum(thisHec1,:) = mean(distum{thisHec1});
    [minDistum(thisHec1,1), minDistum(thisHec1,2)] = min(meanDistum(thisHec1,:));
end
%Get the unique track indexes
[idxUnique, idxNotUnique] = unique(minDistum(:,2));
pairings = [0 0 0];
%pairings(:,1) = Hec1 track numbers
%pairings(:,2) = CenpA track numbers
%pairings(:,3) = min mean distance of the two tracks
%Check for a pairing coming up multiple times and choose the pairing with
%the minimum mean distance between the tracks.
for thisHec1 = 1:numHec1Tracks
    repeatTrack = find(pairings(:,2)==minDistum(thisHec1,2));
    if isempty(repeatTrack)
        pairings(end+1,1) = thisHec1;
        pairings(end,2) = minDistum(thisHec1,2);
        pairings(end,3) = minDistum(thisHec1,1);
    else
        currDist = pairings(repeatTrack(1),3);
        newDist = minDistum(thisHec1,1);
        if newDist < currDist
            pairings(repeatTrack(1),:) = [];
            pairings(end+1,1) = thisHec1;
            pairings(end,2) = minDistum(thisHec1,2);
            pairings(end,3) = minDistum(thisHec1,1);
        end
    end
end
pairings(1,:) = [];

%compile the final distances for each track pair, buy timepoint.
%Put the data in pairings(thisPair, 4:end);
numPairs = length(pairings(:,1));
theImage = getImages(session, imageId);
iUpdate = session.getUpdateService;
for thisPair = 1:numPairs
    hec1Track = pairings(thisPair, 1);
    cenpATrack = pairings(thisPair, 2);
    pairings(thisPair, 4:numT+3) = distum{hec1Track}(:,cenpATrack)';
    
    
    %Save ROIs for Hec1
    roiObjHec1{thisPair} = pojos.ROIData;
    roiObjHec1{thisPair}.setImage(theImage);
    for thisPoint = 1:numT
        pointsHec1{thisPoint} = createPointObj(tracksHec1um{hec1Track}(thisPoint,1)/0.04, tracksHec1um{hec1Track}(thisPoint,2)/0.04, tracksHec1um{hec1Track}(thisPoint,3)/0.125, 1, thisPoint-1, 'none');
        pointsHec1{thisPoint}.setText('Hec1');
        roiObjHec1{thisPair}.addShapeData(pointsHec1{thisPoint});
    end
    savedROI = iUpdate.saveAndReturnObject(roiObjHec1{thisPair}.asIObject);
    
    %Save ROIs for CenpA
    roiObjCenpA{thisPair} = pojos.ROIData;
    roiObjCenpA{thisPair}.setImage(theImage);
    for thisPoint = 1:numT
        pointsCenpA{thisPoint} = createPointObj(tracksCenpAum{cenpATrack}(thisPoint,1)/0.04, tracksCenpAum{cenpATrack}(thisPoint,2)/0.04, tracksCenpAum{cenpATrack}(thisPoint,3)/0.125, 0, thisPoint-1, 'none');
        pointsCenpA{thisPoint}.setText('CenpA');
        roiObjCenpA{thisPair}.addShapeData(pointsCenpA{thisPoint});
    end
    savedROI = iUpdate.saveAndReturnObject(roiObjCenpA{thisPair}.asIObject);
    

end


%Define the metaphase plate for each time point.
[fitResultsCenpA, gofsCenpA, fitOutputsCenpA, outliers] = definePlate(spotFeaturesCenpA);

%Measure the distance from the plate to each CenpA point used for analysis.
fitOutputsCenpA = residualsFromPlate(tracksCenpAum, fitResultsCenpA);

%Measure the distance from the plate to each Hec1 point used for analysis.
fitOutputsHec1 = residualsFromPlate(tracksHec1um, fitResultsCenpA);




% numTracks = length(tlCoords);
% counter = 1;
% iUpdate = session.getUpdateService;
% theImage = getImages(session, imageId);
% counter1 = 1;
% for thisTrack = 1:numTracks
%     tlCoordsdouble{thisTrack}(:,1) = (double(tlCoords{thisTrack}(:,1))); %*0.04;
%     tlCoordsdouble{thisTrack}(:,2) = (double(tlCoords{thisTrack}(:,2))); %*0.04;
%     tlCoordsdouble{thisTrack}(:,3) = (double(tlCoords{thisTrack}(:,3))); %*0.125;
%     
%     spotFeaturesHec1Mapped{thisTrack} = spotFeaturesHec1{thisTrack} + tlCoordsdouble{thisTrack};
%     
%     
%     
%     %Put some ROIs on the server
%     roiObjCenpA{thisTrack} = pojos.ROIData;
%     roiObjCenpA{thisTrack}.setImage(theImage);
%     for thisPoint = 1:numT
%         pointsCenpA{thisPoint} = createPointObj(spotFeaturesForAnalysisCenpA(counter1).x, spotFeaturesForAnalysisCenpA(counter1).y, spotFeaturesForAnalysisCenpA(counter1).z, 1, thisPoint-1, 'none');
%         pointsHec1{thisPoint} = createPointObj(spotFeaturesHec1Mapped{thisTrack}(thisPoint, 1), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 2), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 3), 1, thisPoint-1, 'none');
%         counter1 = counter1 + 1;
%         roiObjCenpA{thisTrack}.addShapeData(pointsCenpA{thisPoint});
%         roiObjCenpA{thisTrack}.addShapeData(pointsHec1{thisPoint});
%     end
%     savedROI = iUpdate.saveAndReturnObject(roiObjCenpA{thisTrack}.asIObject);
%     
% %     roiObjHec1{thisTrack} = pojos.ROIData;
% %     roiObjHec1{thisTrack}.setImage(theImage);
% %     for thisPoint = 1:numT
% %         pointsHec1{thisPoint} = createPointObj(spotFeaturesHec1Mapped{thisTrack}(thisPoint, 1), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 2), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 3), 1, thisPoint-1, 'none');
% %         roiObjHec1{thisTrack}.addShapeData(pointsHec1{thisPoint});
% %     end
% %     savedROI = iUpdate.saveAndReturnObject(roiObjHec1{thisTrack}.asIObject);
%         
%     spotFeaturesHec1Mapped{thisTrack}(:,1) = spotFeaturesHec1Mapped{thisTrack}(:,1) .* 0.04;
%     spotFeaturesHec1Mapped{thisTrack}(:,2) = spotFeaturesHec1Mapped{thisTrack}(:,2) .* 0.04;
%     spotFeaturesHec1Mapped{thisTrack}(:,3) = spotFeaturesHec1Mapped{thisTrack}(:,3) .* 0.125;
%     
%     for thisT = 1:numT
%         spotFeaturesCenpACentroids{thisTrack}(thisT,:) = [spotFeaturesForAnalysisCenpA(counter).x .* 0.04, spotFeaturesForAnalysisCenpA(counter).y .* 0.04, spotFeaturesForAnalysisCenpA(counter).z .* 0.125];
%         cenpA_Hec1_Dist(thisTrack, thisT) = pdist2(spotFeaturesHec1Mapped{thisTrack}(thisT,:), spotFeaturesCenpACentroids{thisTrack}(thisT,:));
%         counter = counter + 1;
%     end
%     
% end
% 
% 
% 
% 
% 
% % 
% % numTracks = length(patchImps);
% % for thisTrack = 1:numTracks
% %     spotFeaturesHec1{thisTrack} = getSpotFeatures(modelHec1{thisTrack});
% %     Hec1Spots{thisTrack}(:,1) = [spotFeaturesHec1{thisTrack}(:).x];
% %     Hec1Spots{thisTrack}(:,2) = [spotFeaturesHec1{thisTrack}(:).y];
% %     Hec1Spots{thisTrack}(:,3) = [spotFeaturesHec1{thisTrack}(:).z];
% %     Hec1Spots{thisTrack}(:,4) = [spotFeaturesHec1{thisTrack}(:).t];
% %     Hec1Spots{thisTrack}(:,5) = [spotFeaturesHec1{thisTrack}(:).id];
% %     Hec1Spots{thisTrack}(:,6) = [spotFeaturesHec1{thisTrack}(:).trackId];
% %     Hec1Spots{thisTrack} = sortrows(Hec1Spots{thisTrack}, 6);
% % end
% 
% 
% %spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, numT)
% 
% 
% %Detect spots and create tracks
% %[trackmateCenpA, modelCenpA, settingsCenpA, trackmateHec1, modelHec1, settingsHec1, numT] = KTTrack(session, imageId);
% 
% %Extract the spot coords and the track they are associated with
% % spotFeaturesCenpA = getSpotFeatures(modelCenpA);
% % spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, numT);
% 
% 
% 
% %Define the metaphase plate for each time point.
% %[fitResultsCenpA, gofsCenpA, fitOutputsCenpA] = definePlate(spotFeaturesCenpA);
% 
% 
% %Measure the distance from each Hec1 point to the plate
% %[fitResultsHec1, gofsHec1, fitOutputsHec1] = residualsFromPlate(spotFeaturesHec1, fitResultsCenpA);
% 
% % % 
% % % %Summarise the distances in specific cells
% % % for thisT = 1:10
% % %     residualsCenpA{thisT} = fitOutputsCenpA{thisT}.residuals;
% % %     residualsHec1{thisT} = fitOutputsHec1{thisT}.residuals;
% % % end
% % % 
% % % 
% % % %Pair up CenpA and Hec1 spots per time point, maybe get the residuals after
% % % %this to avoid having to re-order data all the time.
% % % 
% % % linksCenpA = pairBodies(spotFeaturesForAnalysisCenpA, spotFeaturesForAnalysisHec1);
% 
% 
% 
% %Measure distance between pairs of CenpA and Hec1 spots
% 
% 
% 
% 
% %Identify sisters and measure the distances per time point