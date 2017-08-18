function runFaceForageCSD(subject, pauseBeforeStart)

if nargin < 2
    pauseBeforeStart = true;
    if nargin < 1
        subject = 'Ellie';
    end
end

behavior = @stimuli.forage.faceForageRandomWalk;


% --- parameters for the Hartley noise stimulus
OnDuration       = 2; % time constant on (frames)
OffDuration      = 4; % time constant off (frames)


showCSDFlash       = true;
showNatBackground  = true;
showGaussianBlobs  = false;

settingsStruct = struct();
settingsStruct.display.destinationFactorNew = GL_ONE;
if showNatBackground
    settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;
else
    settingsStruct.display.sourceFactorNew = GL_ONE;
end
settingsStruct.display.colorclamp = 1;
settingsStruct.display.normalizeColor = 1;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount= 0.015; %.015;

settingsStruct.session.subject=subject;

settingsStruct.stimulus.fixWinRadius = 1.5;
settingsStruct.stimulus.fixPointRadius = .3;
settingsStruct.stimulus.holdDuration = 30; % frames (counter, not continuous)

%--------------------------------------------------------------------------
% Add gaussian Pyramid noise
sn='gaussianNoiseBlobs';
settingsStruct.(sn).stateFunction.name='v1mapping.gaussianNoiseBlobs';
settingsStruct.(sn).use=showGaussianBlobs;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
% important parameters
settingsStruct.(sn).N=100; % number in the base level
settingsStruct.(sn).levels=1; % number of levels
settingsStruct.(sn).contrast=0.3;
settingsStruct.(sn).sigma0=0.25;

%--------------------------------------------------------------------------
% Add CSD module
sn='csdFlash';
settingsStruct.(sn).stateFunction.name='v1mapping.csdFlash';
settingsStruct.(sn).use=showCSDFlash;
settingsStruct.(sn).stateFunction.acceptsLocationInput=false;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).onDuration  = 50;
settingsStruct.(sn).offDuration = 150;
settingsStruct.(sn).onColor     = 1;
settingsStruct.(sn).offColor    = .5;

%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name='v1mapping.natImgBackground';
settingsStruct.(sn).use=showNatBackground;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).imageContrast = .5;


if pauseBeforeStart
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

try
    cm = getpref('marmoview_calibration', subject);
    cm2 = cm(:,:,1)';
    cm2(:,:,2) = cm(:,:,2)';
    
    settingsStruct.eyelink.calibration_matrix = cm2;
    settingsStruct.eyelink.useRawData = true;
catch me
    throw(me)
end


% --- Open pldaps
p = pldaps(behavior, settingsStruct);

% --- Build conditions

% --- Condition 1: Face Forage with Hartley Noise
sn  = 'stimulus';
iCond = 1;
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
c{iCond}.(sn).onLifetime  = 1 * 120;
c{iCond}.(sn).offLifetime = 2 * 120;
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
c{iCond}.(sn).onLifetime  = ceil(2 * 120);
c{iCond}.(sn).offLifetime = ceil(3 * 120);
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
    condNums = [condNums ones(1,condN(iCond))*iCond]; %#ok<AGROW>
end

p.defaultParameters.pldaps.finish = 200;

condIdx = repmat(condNums, 1, ceil(p.defaultParameters.pldaps.finish/numel(condNums)));

for iTrial = (numel(p.data)+1):p.defaultParameters.pldaps.finish
    p.conditions{iTrial} = c{condIdx(iTrial)};
end

% --- Run
p.run
