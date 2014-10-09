function [fitResult, gof, fitOutput, outliers] = definePlate(spotFeatures)

t = vertcat(spotFeatures.t);
allT = unique(t)';
ft = fittype( 'poly11' );
counter = 1;

for thisT = allT
    startT = find(t==thisT, 1, 'first');
    endT = find(t==thisT, 1, 'last');
    
    x = vertcat(spotFeatures(startT:endT).x);
    y = vertcat(spotFeatures(startT:endT).y);
    z = vertcat(spotFeatures(startT:endT).z);

    %Fit a line to the coords
    [xData, yData, zData] = prepareSurfaceData(x, y, z);
        
    %Recursively fit model to data, removing outliers.
    [fitResult{counter}, gof{counter}, fitOutput{counter}] = fit([zData, yData], xData, ft);
    
    [outlierIdx,inlierIdx] = detectOutliers(fitOutput{counter}.residuals,3);
    outliers = outlierIdx;
    while ~isempty(outlierIdx)
        numOutliers = length(outlierIdx);
        for thisOutlier = 1:numOutliers
            x(outlierIdx(thisoutlier)) = [];
            y(outlierIdx(thisoutlier)) = [];
            z(outlierIdx(thisoutlier)) = [];
        end
        [fitResult{counter}, gof{counter}, fitOutput{counter}] = fit([zData, yData], xData, ft);
        [outlierIdx,inlierIdx] = detectOutliers(fitOutput{counter}.residuals,3);
        outliers = [outliers; outlierIdx];
    end
    
    
    counter = counter + 1;
end