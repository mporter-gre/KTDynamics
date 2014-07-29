function coords = trackmateCoords(model)

spots = model.getSpots;
spotsIter = spots.iterator(1);
counter = 1;

while spotsIter.hasNext
    spot = spotsIter.next;
    coords(counter).x = spot.getFeature('POSITION_X').doubleValue;
    coords(counter).y = spot.getFeature('POSITION_Y').doubleValue;
    coords(counter).z = spot.getFeature('POSITION_Z').doubleValue;
    coords(counter).t = spot.getFeature('POSITION_T').doubleValue+1;
    coords(counter).id = spot.ID;
    counter = counter + 1;
end