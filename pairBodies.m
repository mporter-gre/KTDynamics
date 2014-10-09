function linksCenpA = pairBodies(spotFeaturesCenpA, spotFeaturesHec1)

numCenpA = length(spotFeaturesCenpA);
numHec1 = length(spotFeaturesHec1);

for thisSpot = 1:numCenpA
    cenpACoords(thisSpot,:) = [spotFeaturesCenpA(thisSpot).x spotFeaturesCenpA(thisSpot).y spotFeaturesCenpA(thisSpot).z spotFeaturesCenpA(thisSpot).t];
end

cenpACoords = sortrows(cenpACoords, 4);

uniqueT = unique(cenpACoords(:,4))';
numT = length(uniqueT);

counter = 1;

%figure; hold on;

for thisT = uniqueT
    idx1 = find(cenpACoords(:,4)==thisT, 1, 'first');
    idx2 = find(cenpACoords(:,4)==thisT, 1, 'last');
    
    cenpACoordsThisT = cenpACoords(idx1:idx2,1:3);
    
    cenpADist = pdist(cenpACoordsThisT);
    cenpADist = squareform(cenpADist);
    
    cenpADistToFilt = cenpADist;
    cenpADistToFilt(cenpADistToFilt>3) = -1;
    cenpADistToFilt(cenpADistToFilt==0) = -1;
    
    cenpADistFilt{counter} = cenpADistToFilt;
    [linksCenpA{counter}, ~] = lap(cenpADistFilt{counter},-1,0,1);
    counter = counter + 1;
end

cenpADistFiltMean = mean(cenpADistFilt,3);
cenpADistFiltVar = var(cenpADistFilt,0,3);  %Use variance instead????
costMat = cenpADistFiltMean .* cenpADistFiltVar;

cenpADistFiltCosted = cenpADistFilt;
for thisT = 1:10
    cenpADistFiltCosted(:,:,thisT) = cenpADistFiltCosted(:,:,thisT) .* costMat;
    [linksCenpACosted(:,thisT), ~] = lap(cenpADistFilt(:,:,thisT),-1,0,1);
end
   



    
    
    
%     try
%     onePair = linksCenpA(1,counter);
%     scatter3(cenpACoordsThisT(1,1), cenpACoordsThisT(1,2), cenpACoordsThisT(1,3), 'k');
%     scatter3(cenpACoordsThisT(onePair,1), cenpACoordsThisT(onePair,2), cenpACoordsThisT(onePair,3), 'k', 'fill');
%     
%     twoPair = linksCenpA(2,counter);
%     scatter3(cenpACoordsThisT(2,1), cenpACoordsThisT(2,2), cenpACoordsThisT(2,3), 'g');
%     scatter3(cenpACoordsThisT(twoPair,1), cenpACoordsThisT(twoPair,2), cenpACoordsThisT(twoPair,3), 'g', 'fill');
%     
%     threePair = linksCenpA(3,counter);
%     scatter3(cenpACoordsThisT(3,1), cenpACoordsThisT(3,2), cenpACoordsThisT(3,3), 'r');
%     scatter3(cenpACoordsThisT(threePair,1), cenpACoordsThisT(threePair,2), cenpACoordsThisT(threePair,3), 'r', 'fill');
%     
%     fourPair = linksCenpA(4,counter);
%     scatter3(cenpACoordsThisT(4,1), cenpACoordsThisT(4,2), cenpACoordsThisT(4,3), 'c');
%     scatter3(cenpACoordsThisT(fourPair,1), cenpACoordsThisT(fourPair,2), cenpACoordsThisT(fourPair,3), 'c', 'fill');
%     
%     fivePair = linksCenpA(5,counter);
%     scatter3(cenpACoordsThisT(5,1), cenpACoordsThisT(5,2), cenpACoordsThisT(5,3), 'm');
%     scatter3(cenpACoordsThisT(fivePair,1), cenpACoordsThisT(fivePair,2), cenpACoordsThisT(fivePair,3), 'm', 'fill');
%     
%     sixPair = linksCenpA(6,counter);
%     scatter3(cenpACoordsThisT(6,1), cenpACoordsThisT(6,2), cenpACoordsThisT(6,3), 'y');
%     scatter3(cenpACoordsThisT(sixPair,1), cenpACoordsThisT(sixPair,2), cenpACoordsThisT(sixPair,3), 'y', 'fill');
%     
%     sevenPair = linksCenpA(7,counter);
%     scatter3(cenpACoordsThisT(7,1), cenpACoordsThisT(7,2), cenpACoordsThisT(7,3), 'b', 'fill');
%     scatter3(cenpACoordsThisT(sevenPair,1), cenpACoordsThisT(sevenPair,2), cenpACoordsThisT(sevenPair,3), 'b', 'fill');
%     
% %     eightPair = linksCenpA(8,counter);
% %     scatter3(cenpACoordsThisT(8,1), cenpACoordsThisT(8,2), cenpACoordsThisT(8,3), 'g', 'fill');
% %     scatter3(cenpACoordsThisT(eightPair,1), cenpACoordsThisT(eightPair,2), cenpACoordsThisT(eightPair,3), 'g', 'fill');
% %     
% %     ninePair = linksCenpA(9,counter);
% %     scatter3(cenpACoordsThisT(9,1), cenpACoordsThisT(9,2), cenpACoordsThisT(9,3), 'b', 'fill');
% %     scatter3(cenpACoordsThisT(ninePair,1), cenpACoordsThisT(ninePair,2), cenpACoordsThisT(ninePair,3), 'b', 'fill');
%     catch
%         counter = counter + 1;
%         continue;
%     end
%     counter = counter + 1;


for thisSpot = 1:numCenpA
        linksThisSpot = linksCenpA(thisSpot, :);
        linksTab = tabulate(linksThisSpot);
        percentWin = linksTab(:,3);
        numCandidates = length(percentWin(percentWin>0));
        if numCandidates == 1
            sisterPair(thisSpot) = linksThisSpot(1);
        else
            maxPercent = max(percentWin);
            maxIdx = find(percentWin==maxPercent);
            numAtMax = length(maxIdx);
            if numAtMax > 1
                secondMaxIdx = maxIdx(2);
                maxIdx = maxIdx(1);
            else
                secondMax = max(percentWin(percentWin~=max(percentWin)));
                secondMaxIdx = find(percentWin==secondMax);
            end
            maxMeanDist = cenpADistFiltMean(thisSpot, maxIdx);
            maxStdDist = cenpADistFiltStd(thisSpot, maxIdx);
            secondMaxMeanDist = cenpADistFiltMean(thisSpot, secondMaxIdx);
            secondMasStdDist = cenpADistFiltStd(thisSpot, secondMaxIdx);
        end
end

