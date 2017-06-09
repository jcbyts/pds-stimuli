function p = updateConditions(p, sn)

if nargin < 2
    sn = 'stimulus';
end

% --- Condition 1: Grating Forage with Gaussian Pyramid Noise
iCond = 1;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN       = 2;  % number of face objects
c{iCond}.(sn).minSpeed   = 3;  % minumum speed of face objects
c{iCond}.(sn).maxSpeed   = 8;
c{iCond}.(sn).motionType = 'randomwalk'; % randomwalk or linear
c{iCond}.(sn).type       = 'face';  % face or grating
c{iCond}.(sn).appearGazeContingent = false;
c{iCond}.(sn).appearRangePar = 2;
c{iCond}.(sn).appearCenter = [0 -2];
c{iCond}.(sn).appearTau = 1;
c{iCond}.(sn).maxContrast = 0.3;
c{iCond}.(sn).radius = 1;
c{iCond}.(sn).onLifetime  = 1 * p.trial.display.frate;
c{iCond}.(sn).offLifetime = 2 * p.trial.display.frate;
c{iCond}.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
    'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
% --- modules
c{iCond}.natImgBackground.use        = false;
c{iCond}.natImgBackground.on         = false;
c{iCond}.gaussianNoiseBlobs.use      = true;
c{iCond}.gaussianNoiseBlobs.contrast = .3;
c{iCond}.hartley.use                 = false;
c{iCond}.csdFlash.use                = false;
% % 
% --- Condition 2: Face Forage on Natural background
iCond = 2;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN       = 3;  % number of face objects
c{iCond}.(sn).minSpeed   = 0;
c{iCond}.(sn).maxSpeed   = 0;
c{iCond}.(sn).motionType = 'randomwalk';
c{iCond}.(sn).type       = 'face'; 
c{iCond}.(sn).appearGazeContingent = false;
c{iCond}.(sn).appearRangePar = 3;
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
% % 
% % % --- Condition: Face  on Hartley
iCond = iCond+1;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN       = 2;  % number of face objects
c{iCond}.(sn).minSpeed   = 5;
c{iCond}.(sn).maxSpeed   = 10;
c{iCond}.(sn).motionType = 'randomwalk';
c{iCond}.(sn).type       = 'face'; 
c{iCond}.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
    'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
c{iCond}.(sn).appearGazeContingent = false;
c{iCond}.(sn).appearRangePar       = 3;
c{iCond}.(sn).appearCenter         = [0 -2];
c{iCond}.(sn).appearTau            = 100;
c{iCond}.(sn).maxContrast          = 0.5;
c{iCond}.(sn).radius               = 1;
c{iCond}.(sn).onLifetime           = 2 * p.trial.display.frate;
c{iCond}.(sn).offLifetime          = 2 * p.trial.display.frate;
% --- modules
c{iCond}.natImgBackground.use   = false;
c{iCond}.natImgBackground.on    = false;
c{iCond}.gaussianNoiseBlobs.use = false;
c{iCond}.csdFlash.use           = false;
c{iCond}.hartley.use            = true;
c{iCond}.hartley.OnDuration     = 2;
c{iCond}.hartley.OffDuration    = 4;       
c{iCond}.hartley.contrast       = .1;
c{iCond}.hartley.tfs            = 0; %[0 2 4 8 16];
c{iCond}.hartley.sfscale        = 1;
c{iCond}.hartley.nOctaves       = 5;
c{iCond}.hartley.Freq0          =.5;

% --- Condition 3: Face Forage with CSD flash
iCond = iCond+1;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN       = 2;  % number of face objects
c{iCond}.(sn).minSpeed   = 1;
c{iCond}.(sn).maxSpeed   = 3;
c{iCond}.(sn).motionType = 'randomwalk';
c{iCond}.(sn).type       = 'face'; 
c{iCond}.(sn).appearGazeContingent = false;
c{iCond}.(sn).appearRangePar = 5;
c{iCond}.(sn).appearCenter = [0 0];
c{iCond}.(sn).appearTau = 1;
c{iCond}.(sn).maxContrast = .5;
c{iCond}.(sn).radius = 1;
c{iCond}.(sn).onLifetime  = 1 * p.trial.display.frate;
c{iCond}.(sn).offLifetime = 2 * p.trial.display.frate;
c{iCond}.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
    'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
% --- modules
c{iCond}.natImgBackground.use = false;
c{iCond}.natImgBackground.on = false;
c{iCond}.gaussianNoiseBlobs.use = false;
c{iCond}.hartley.use = false;
c{iCond}.csdFlash.use = true;
c{iCond}.csdFlash.onDuration = 50;
c{iCond}.csdFlash.offDuration = 150;
c{iCond}.csdFlash.onColor = 1;
c{iCond}.csdFlash.offColor = .2;
% 
% % --- Condition 4: Face Invaders on Natural background
% iCond = iCond+1;
% c{iCond} = struct(sn, struct());
% c{iCond}.Nr = iCond;
% c{iCond}.(sn).MotN       = 15;  % number of face objects
% c{iCond}.(sn).minSpeed   = 5;
% c{iCond}.(sn).maxSpeed   = 10;
% c{iCond}.(sn).motionType = 'linear';
% c{iCond}.(sn).type       = 'face'; 
% c{iCond}.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
%     'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
% c{iCond}.(sn).appearGazeContingent = false;
% c{iCond}.(sn).appearRangePar = 5;
% c{iCond}.(sn).appearCenter = [0 0];
% c{iCond}.(sn).appearTau = 100;
% c{iCond}.(sn).maxContrast = 0.5;
% c{iCond}.(sn).radius = 1;
% c{iCond}.(sn).onLifetime  = 2 * p.trial.display.frate;
% c{iCond}.(sn).offLifetime = 2 * p.trial.display.frate;
% % --- modules
% c{iCond}.natImgBackground.use = true;
% c{iCond}.natImgBackground.on = true;
% c{iCond}.gaussianNoiseBlobs.use = false;
% c{iCond}.hartley.use = false;
% c{iCond}.csdFlash.use = false;


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
