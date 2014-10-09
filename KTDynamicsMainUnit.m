%KTDynamicsMainUnit

%get the cenpA tracks...
[trackmateCenpA, modelCenpA, settingsCenpA, numT] = trackCenpA(session, imageId);

%Extract the spots and filter for full-length tracks
spotFeaturesCenpA = getSpotFeatures(modelCenpA);
spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, numT);

%For each track, cut out the region and track Hec1
[patchImps, tlCoords, tileStack, tileStackCenpA] = createPatchTimeStacks(session, imageId, spotFeaturesForAnalysisCenpA, numT);

[trackmateHec1, modelHec1, settingsHec1, spotFeaturesHec1] = trackHec1(patchImps, 2);


numTracks = length(tlCoords);
counter = 1;
iUpdate = session.getUpdateService;
theImage = getImages(session, imageId);
counter1 = 1;
for thisTrack = 1:numTracks
    tlCoordsdouble{thisTrack}(:,1) = (double(tlCoords{thisTrack}(:,1))); %*0.04;
    tlCoordsdouble{thisTrack}(:,2) = (double(tlCoords{thisTrack}(:,2))); %*0.04;
    tlCoordsdouble{thisTrack}(:,3) = (double(tlCoords{thisTrack}(:,3))); %*0.125;
    
    spotFeaturesHec1Mapped{thisTrack} = spotFeaturesHec1{thisTrack} + tlCoordsdouble{thisTrack};
    
    
    
    %Put some ROIs on the server
    roiObjCenpA{thisTrack} = pojos.ROIData;
    roiObjCenpA{thisTrack}.setImage(theImage);
    for thisPoint = 1:numT
        pointsCenpA{thisPoint} = createPointObj(spotFeaturesForAnalysisCenpA(counter1).x, spotFeaturesForAnalysisCenpA(counter1).y, spotFeaturesForAnalysisCenpA(counter1).z, 1, thisPoint-1, 'none');
        pointsHec1{thisPoint} = createPointObj(spotFeaturesHec1Mapped{thisTrack}(thisPoint, 1), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 2), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 3), 1, thisPoint-1, 'none');
        counter1 = counter1 + 1;
        roiObjCenpA{thisTrack}.addShapeData(pointsCenpA{thisPoint});
        roiObjCenpA{thisTrack}.addShapeData(pointsHec1{thisPoint});
    end
    savedROI = iUpdate.saveAndReturnObject(roiObjCenpA{thisTrack}.asIObject);
    
%     roiObjHec1{thisTrack} = pojos.ROIData;
%     roiObjHec1{thisTrack}.setImage(theImage);
%     for thisPoint = 1:numT
%         pointsHec1{thisPoint} = createPointObj(spotFeaturesHec1Mapped{thisTrack}(thisPoint, 1), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 2), spotFeaturesHec1Mapped{thisTrack}(thisPoint, 3), 1, thisPoint-1, 'none');
%         roiObjHec1{thisTrack}.addShapeData(pointsHec1{thisPoint});
%     end
%     savedROI = iUpdate.saveAndReturnObject(roiObjHec1{thisTrack}.asIObject);
        
    spotFeaturesHec1Mapped{thisTrack}(:,1) = spotFeaturesHec1Mapped{thisTrack}(:,1) .* 0.04;
    spotFeaturesHec1Mapped{thisTrack}(:,2) = spotFeaturesHec1Mapped{thisTrack}(:,2) .* 0.04;
    spotFeaturesHec1Mapped{thisTrack}(:,3) = spotFeaturesHec1Mapped{thisTrack}(:,3) .* 0.125;
    
    for thisT = 1:numT
        spotFeaturesCenpACentroids{thisTrack}(thisT,:) = [spotFeaturesForAnalysisCenpA(counter).x .* 0.04, spotFeaturesForAnalysisCenpA(counter).y .* 0.04, spotFeaturesForAnalysisCenpA(counter).z .* 0.125];
        cenpA_Hec1_Dist(thisTrack, thisT) = pdist2(spotFeaturesHec1Mapped{thisTrack}(thisT,:), spotFeaturesCenpACentroids{thisTrack}(thisT,:));
        counter = counter + 1;
    end
    
end





% 
% numTracks = length(patchImps);
% for thisTrack = 1:numTracks
%     spotFeaturesHec1{thisTrack} = getSpotFeatures(modelHec1{thisTrack});
%     Hec1Spots{thisTrack}(:,1) = [spotFeaturesHec1{thisTrack}(:).x];
%     Hec1Spots{thisTrack}(:,2) = [spotFeaturesHec1{thisTrack}(:).y];
%     Hec1Spots{thisTrack}(:,3) = [spotFeaturesHec1{thisTrack}(:).z];
%     Hec1Spots{thisTrack}(:,4) = [spotFeaturesHec1{thisTrack}(:).t];
%     Hec1Spots{thisTrack}(:,5) = [spotFeaturesHec1{thisTrack}(:).id];
%     Hec1Spots{thisTrack}(:,6) = [spotFeaturesHec1{thisTrack}(:).trackId];
%     Hec1Spots{thisTrack} = sortrows(Hec1Spots{thisTrack}, 6);
% end


%spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, numT)


%Detect spots and create tracks
%[trackmateCenpA, modelCenpA, settingsCenpA, trackmateHec1, modelHec1, settingsHec1, numT] = KTTrack(session, imageId);

%Extract the spot coords and the track they are associated with
% spotFeaturesCenpA = getSpotFeatures(modelCenpA);
% spotFeaturesForAnalysisCenpA = getLongTracks(spotFeaturesCenpA, numT);



%Define the metaphase plate for each time point.
%[fitResultsCenpA, gofsCenpA, fitOutputsCenpA] = definePlate(spotFeaturesCenpA);


%Measure the distance from each Hec1 point to the plate
%[fitResultsHec1, gofsHec1, fitOutputsHec1] = residualsFromPlate(spotFeaturesHec1, fitResultsCenpA);

% % 
% % %Summarise the distances in specific cells
% % for thisT = 1:10
% %     residualsCenpA{thisT} = fitOutputsCenpA{thisT}.residuals;
% %     residualsHec1{thisT} = fitOutputsHec1{thisT}.residuals;
% % end
% % 
% % 
% % %Pair up CenpA and Hec1 spots per time point, maybe get the residuals after
% % %this to avoid having to re-order data all the time.
% % 
% % linksCenpA = pairBodies(spotFeaturesForAnalysisCenpA, spotFeaturesForAnalysisHec1);



%Measure distance between pairs of CenpA and Hec1 spots




%Identify sisters and measure the distances per time point