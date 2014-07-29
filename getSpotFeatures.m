function spotFeatures = getSpotFeatures(model)
%spotFeatures = getSpotFeatures(model)
%'model' is the model object returned from trackmate.
%Retreive the x y z t and id of each spot in model

spots = model.getSpots;
tracks = model.getTrackModel;
spotsIter = spots.iterator(1);
counter = 1;

while spotsIter.hasNext
    thisSpot = spotsIter.next;
    spotFeatures(counter).x = thisSpot.getFeature('POSITION_X').doubleValue;
    spotFeatures(counter).y = thisSpot.getFeature('POSITION_Y').doubleValue;
    spotFeatures(counter).z = thisSpot.getFeature('POSITION_Z').doubleValue;
    spotFeatures(counter).t = thisSpot.getFeature('POSITION_T').doubleValue;
    spotFeatures(counter).id = thisSpot.ID;
    
    trackId = tracks.trackIDOf(thisSpot);
    if isempty(trackId)
        spotFeatures(counter).trackId = inf;
    else
        spotFeatures(counter).trackId = trackId.intValue;
    end
    
    counter = counter + 1;
end