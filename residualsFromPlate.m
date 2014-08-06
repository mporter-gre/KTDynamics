function [fitResult, gof, fitOutput] = residualsFromPlate(spotFeatures, plateFcn)

t = vertcat(spotFeatures.t);
allT = unique(t)';
counter = 1;

for thisT = allT
    startT = find(t==thisT, 1, 'first');
    endT = find(t==thisT, 1, 'last');
    
    x = vertcat(spotFeatures(startT:endT).x);
    y = vertcat(spotFeatures(startT:endT).y);
    z = vertcat(spotFeatures(startT:endT).z);
    
    [fitResult, gof, fitOutput] = fit([z, y], x, plateFcn);
end