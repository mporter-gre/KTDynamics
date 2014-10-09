function [trackmateHec1, modelHec1, settingsHec1, spotFeaturesHec1] = trackHec1(patchImps, maxSpots)

Miji(true);


numTracks = length(patchImps);

for thisTrack = 1:numTracks
    numT = length(patchImps{thisTrack});
    for thisT = 1:numT
        %Optimise detection
        [modelHec1{thisTrack}{thisT}, settingsHec1{thisTrack}{thisT}, trackmateHec1{thisTrack}{thisT}] = optimiseTrackMateHec1(patchImps{thisTrack}{thisT}, maxSpots);
        %[trackmateHec1{thisTrack}, modelHec1{thisTrack}, settingsHec1{thisTrack}] = trackmateTracking(modelHec1{thisTrack}, settingsHec1{thisTrack}, patchImps{thisTrack});
    end
    %Paste the single spots found on optimisation together to make a track
    %manually.
    for thisT = 1:numT
        spots{thisT} = modelHec1{thisTrack}{thisT}.getSpots;
        numSpots(thisT) = spots{thisT}.getNSpots(0);
        if numSpots(thisT) == 0
            disp('no spots');
            continue;
        end
        spotsIter = spots{thisT}.iterator(1);
        thisSpot = spotsIter.next;
        spotFeaturesHec1{thisTrack}(thisT,1) = thisSpot.getFeature('POSITION_X').doubleValue;
        spotFeaturesHec1{thisTrack}(thisT,2) = thisSpot.getFeature('POSITION_Y').doubleValue;
        spotFeaturesHec1{thisTrack}(thisT,3) = thisSpot.getFeature('POSITION_Z').doubleValue;
    end
    

end