function [stdObjDist, meanObjDist, objDist] = objectDistances(objData1, objData2)
%objData1 is a single set of observations (time points) while objData2 has
%rows of obeservations in cells relating to many other objects.

numHec1 = length(objData1);
numTracks = length(objData2);
for thisHec1 = 1:numHec1
    for thisTrack = 1:numTracks
        distances = pdist2(objData1{thisHec1}(:,2:4), objData2{thisTrack}(:,2:4));
        objDist{thisHec1}(:,thisTrack) = distances(:,1);
    end
    meanObjDist{thisHec1} = mean(objDist{thisHec1});
    stdObjDist{thisHec1} = std(objDist{thisHec1});
end
