function p = conditionsFreeViewNI(p, sn)

if nargin < 2
    sn = 'stimulus';
end


iCond = 1;
% --- Condition 1: Face Forage on Natural background
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
% --- modules
c{iCond}.natImgBackground.use   = true;
c{iCond}.natImgBackground.on    = true;
c{iCond}.gaussianNoiseBlobs.use = false;
c{iCond}.hartley.use            = false;
c{iCond}.csdFlash.use           = false;


% --- setup number of conditions        
condN = ones(1,iCond);
condN(1) = 3;

condNums = [];
for iCond = 1:numel(c)
    condNums = [condNums ones(1,condN(iCond))*iCond];
end

condIdx = repmat(condNums, 1, ceil(p.defaultParameters.pldaps.finish/numel(condNums)));

for iTrial = (numel(p.data)+1):p.defaultParameters.pldaps.finish
    p.conditions{iTrial} = c{condIdx(iTrial)};
end
