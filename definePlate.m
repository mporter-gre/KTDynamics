function [fitResult, gof, fitOutput] = definePlate(spotFeatures)

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
        
    % Fit model to data.
    [fitResult{counter}, gof{counter}, fitOutput{counter}] = fit([zData, yData], xData, ft);
    counter = counter + 1;
end