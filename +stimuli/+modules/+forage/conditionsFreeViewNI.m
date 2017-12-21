function p = conditionsFreeViewNI(p, sn)

if nargin < 2
    sn = 'stimulus';
end


iCond = 1;

% --- Condition 1: Face Forage on Natural background
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN       = 3;  % number of face objects
c{iCond}.(sn).minSpeed   = 0;
c{iCond}.(sn).maxSpeed   = 0;
c{iCond}.(sn).motionType = 'randomwalk';
c{iCond}.(sn).type       = 'face'; 
c{iCond}.(sn).appearGazeContingent = false;
c{iCond}.(sn).appearRangePar = 2;
c{iCond}.(sn).appearCenter = [0 -2];
c{iCond}.(sn).appearTau = 60; % in frames
c{iCond}.(sn).maxContrast = 0.5;
c{iCond}.(sn).radius = 1;
c{iCond}.(sn).onLifetime  = ceil(2 * p.trial.display.frate);
c{iCond}.(sn).offLifetime = ceil(3 * p.trial.display.frate);
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
