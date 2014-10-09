time = 1:10;
nGoodTracks = length(spotFeaturesForAnalysisCenpA);

% preassign matrices
[variances,distances,alignment,overlapCost,pairCands] = deal([]);

% read track coordinates etc.
numCenpA = length(spotFeaturesForAnalysisCenpA);
for thisSpot = 1:numCenpA
    coords{thisSpot,:} = [spotFeaturesForAnalysisCenpA(thisSpot).x spotFeaturesForAnalysisCenpA(thisSpot).y spotFeaturesForAnalysisCenpA(thisSpot).z spotFeaturesForAnalysisCenpA(thisSpot).t];
end

[coords,coordsStd,amp,ampStd,time,idx] = deal(cell(nGoodTracks,1));
for i=1:nGoodTracks
    [coords{i},coordsStd{i},amp{i},ampStd{i},time{i},idx{i}] = getTrackData(tracks(goodTracks(i)));
    coords{i} = spotFeaturesForAnalysisCenpA(
end

%loop through the good tracks and calculate grouping cost elements
iPair=0;
for jTrack = 1:nGoodTracks % loop cols
    
%     % plot individual tracks
%     if verbose == 2
%         plot(coords{jTrack}(:,1),coords{jTrack}(:,2),'Color',extendedColors(jTrack))
%     end
    
    for iTrack = jTrack+1:nGoodTracks % loop rows 
        
        % find common time
        [commonTime,ctColIdx,ctRowIdx] = intersect(time{jTrack},time{iTrack});
        numOverlapFrames = length(commonTime);
        
        %if the common time between the two tracks is at least minOverlap,
        %calculate parameters (otherwise, they stay as NaN, which assigns
        %them -1 in linkTracks)
        if numOverlapFrames < minOverlap, continue; end
        
        % calculate distance
        distanceVector = coords{jTrack}(idx{jTrack}(ctColIdx),:) -...
            coords{iTrack}(idx{iTrack}(ctRowIdx),:);
        [distance,distanceVectorN] = normList(distanceVector);
        
        if useAlignment
            
            %get the angle between distance vector and spindle axis
            numDim = size(spindleAxisVec,2);
            distanceDotAxis = sum(distanceVectorN(:,1:numDim) .* spindleAxisVec(commonTime,:),2);
            alpha = acos(abs(distanceDotAxis));
            
            % average alpha, rather than tan to be nice to pairs that will
            % align eventually. Potentially this can be put under the control
            % of the "robust" switch, too
            %average alpha only over frames where there is a plane (the
            %rest are NaN). If none of the frames have a plane, the average
            %will be NaN.
            %also get the standard deviation of alpha
            meanAlpha = nanmean(alpha);
            stdAlpha = nanstd(alpha); %#ok<NASGU>
            
        end
        
        if useAlignment && meanAlpha > maxAngle, continue; end
        
        % get distance mean and standard deviation
        if robust
            [rMean,rStd]=robustMean(distance);
        else
            rMean = mean(distance);
            rStd = std(distance);
        end
        
        if rMean > maxDist, continue; end
        
        % Add tracks pair to the list of candidate sisters
        iPair=iPair+1;
        pairCands(iPair,:)= [iTrack,jTrack];
        
        %assign distance mean for pair
        distances(iPair,1) = rMean;
        
        %assign distance variance for pair
        variances(iPair,1) = rStd^2;
        
        %assign alignment cost for pair if the average angle is less
        %than maxAngle degrees. Otherwise, keep as NaN to prohibit the link
        if useAlignment
            alignment(iPair,1) = 2*sqrt(3)*tan(meanAlpha)+1;
        else
            alignment(iPair,1) = NaN;
        end
        
        %assign overlap cost - the longer the overlap, the lower the
        %cost
        overlapCost(iPair,1) = sqrt( 10 / numOverlapFrames );
        
    end %(for iTrack = jTrack+1:nGoodTracks)
    
end %(for jTrack = 1:nGoodTracks)

%% CREATE COST MATRIX & GROUP

costMat = distances.*variances.*overlapCost;
if useAlignment
    costMat = costMat.*alignment;
end
m=maxWeightedMatching(nGoodTracks,pairCands,1./costMat);

if ~any(m)
    sisterList = struct('coords1',[],...
        'coords2',[],'sisterVectors',[],'distances',[]);
    trackPairs=[];
    return;
end

%get the median sister distance in order to recalculate the costs and make
%a new assignment in which, instead of favoring the smallest distance, one
%favors the distances closest to the average distance
sisterDistAve = median(distances(m));

costMat = max(abs(distances-sisterDistAve),eps).*variances.*overlapCost;
if useAlignment
    costMat = costMat.*alignment;
end
m=maxWeightedMatching(nGoodTracks,pairCands,1./costMat);

if ~any(m)
    sisterList = struct('coords1',[],...
        'coords2',[],'sisterVectors',[],'distances',[]);
    trackPairs=[];
    return;
end

%% ASSEMBLE SISTER INFORMATION

nGoodPairs = sum(m);
sisterList(1:nGoodPairs,1) = ...
    struct('coords1',NaN(nTimepoints,6),'coords2',NaN(nTimepoints,6),...
    'sisterVectors',NaN(nTimepoints,6),'distances',NaN(nTimepoints,2),...
    'amp1',NaN(nTimepoints,2),'amp2',NaN(nTimepoints,2),...
    'poleAssign12',NaN(nTimepoints,2),...
    'vecFromPole1',NaN(nTimepoints,6),'vecFromPole2',NaN(nTimepoints,6));

% write trackPairs. Store: pair1,pair2,cost,dist,var,alignment
trackPairs = ...
    [goodTracks(pairCands(m,1)),goodTracks(pairCands(m,2)),...
    costMat(m),distances(m),variances(m),alignment(m)];
trackPairs(isnan(trackPairs(:,6)),6) = 0;

% loop over trackPairs to get sister information
validPairs= find(m);
for i=1:numel(validPairs)
    iPair = validPairs(i);
    
    %get information for first sister
    rowCoords = coords{pairCands(iPair,1)};
    rowCoordsStd = coordsStd{pairCands(iPair,1)};
    rowTime  = time{pairCands(iPair,1)};
    rowIdx = idx{pairCands(iPair,1)};
    rowAmp = amp{pairCands(iPair,1)};
    rowAmpStd = ampStd{pairCands(iPair,1)};
    
    %get information for second sister
    colCoords = coords{pairCands(iPair,2)};
    colCoordsStd = coordsStd{pairCands(iPair,2)};
    colTime  = time{pairCands(iPair,2)};
    colIdx = idx{pairCands(iPair,2)};
    colAmp = amp{pairCands(iPair,2)};
    colAmpStd = ampStd{pairCands(iPair,2)};
    
    %find common time between them
    [commonTime,ctColIdx,ctRowIdx] = intersect(colTime,rowTime);
    
    %store first sister information
    sisterList(i).coords1(commonTime,:) = ...
        [rowCoords(rowIdx(ctRowIdx),:) rowCoordsStd(rowIdx(ctRowIdx),:)];
    sisterList(i).amp1(commonTime,:) = ...
        [rowAmp(rowIdx(ctRowIdx),:) rowAmpStd(rowIdx(ctRowIdx),:)];
    
    %store second sister information
    sisterList(i).coords2(commonTime,:) = ...
        [colCoords(colIdx(ctColIdx),:) colCoordsStd(colIdx(ctColIdx),:)];
    sisterList(i).amp2(commonTime,:) = ...
        [colAmp(colIdx(ctColIdx),:) colAmpStd(colIdx(ctColIdx),:)];
    
    %calculate the vector connecting the two sisters and its std
    sisterVectors = [colCoords(colIdx(ctColIdx),:) - rowCoords(rowIdx(ctRowIdx),:) ...
        sqrt(colCoordsStd(colIdx(ctColIdx),:).^2 + rowCoordsStd(rowIdx(ctRowIdx),:).^2)];
    sisterList(i).sisterVectors(commonTime,:) = sisterVectors;
    
    %calculate the distance between the two sisters and its std
    sisterDist = sqrt(sum(sisterVectors(:,1:3).^2,2));
    sisterDistStd = sqrt(sum((sisterVectors(:,1:3)./repmat(sisterDist,1,3)).^2 .* ...
        sisterVectors(:,4:6).^2,2));
    sisterList(i).distances(commonTime,:) = [sisterDist sisterDistStd];
    
end % loop goodPairs