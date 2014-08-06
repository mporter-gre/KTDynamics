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
    
    [fitResult{thisT+1}, gof{thisT+1}, fitOutput{thisT+1}] = fit([z, y], x, plateFcn{thisT+1});
end