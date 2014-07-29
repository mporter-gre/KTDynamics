function spotsOut = getLongTracks(spots, minLength)

spotsTable = struct2table(spots);
[spotsTable] = sortrows(spotsTable, 6);
sortedSpots = table2struct(spotsTable)';
trackIds = squeeze(table2array(spotsTable(:,6)));
trackIdsUnique = unique(trackIds);
spotsOut = struct('x',[],'y',[],'z',[],'t',[],'id',[],'trackId',[]);

trackLengths = histc(trackIds, trackIdsUnique);

numTracks = length(trackLengths);

for thisTrack = 1:numTracks
    if trackLengths(thisTrack) < minLength
        continue;
    end
    
    trackStart = find(trackIds==trackIdsUnique(thisTrack), 1, 'first');
    trackEnd = find(trackIds==trackIdsUnique(thisTrack), 1, 'last');
    
    spotsOut = [spotsOut sortedSpots(trackStart:trackEnd)];
end

spotsOut(1) = [];