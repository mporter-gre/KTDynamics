function fitOutput = residualsFromPlate(tracksIn, plateFcn)


numTracks = length(tracksIn);
numT = length(tracksIn{1});
fitOutput = cell(numT,1);

for thisT = 1:numT
    for thisTrack = 1:numTracks
        x(thisTrack,1) = tracksIn{thisTrack}(thisT,1);
        y(thisTrack,1) = tracksIn{thisTrack}(thisT,2);
        z(thisTrack,1) = tracksIn{thisTrack}(thisT,3);
    end
    [~, ~, fitOutput{thisT}]= fit([z, y], x, plateFcn{thisT});
    x = [];
    y = [];
    z = [];
end