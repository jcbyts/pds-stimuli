function runFaceForageHartley(subject, pauseBeforeStart)

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
hartleyContrast  = .15; % contrast of the gratings
nOctaves         = 5;   % number of octaves
Freq0            =.5;   % base spatial frequency



showCSDFlash       = false;
showNatBackground  = true;
showHartleyStimuli = true;
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
settingsStruct.behavior.reward.defaultAmount= 0.05; %.015;

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


%--------------------------------------------------------------------------
% Add Hartley Stimulus
sn='hartley';
settingsStruct.(sn).stateFunction.name='v1mapping.hartleyStimuli';
settingsStruct.(sn).use=showHartleyStimuli;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).OnDuration  = OnDuration;
settingsStruct.(sn).OffDuration = OffDuration;
settingsStruct.(sn).contrast    = hartleyContrast;
settingsStruct.(sn).Freq0       = Freq0;
settingsStruct.(sn).nOctaves    = nOctaves;
settingsStruct.(sn).tfs         = 0;
settingsStruct.(sn).sfscale     = 1;


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
c{iCond}.(sn).minSpeed   = 3;  % minumum speed of face objects
c{iCond}.(sn).maxSpeed   = 8;
c{iCond}.(sn).motionType = 'randomwalk'; % randomwalk or linear
c{iCond}.(sn).type       = 'face';       % face or grating
c{iCond}.(sn).appearGazeContingent = false;
c{iCond}.(sn).appearRangePar = 2;
c{iCond}.(sn).appearCenter = [0 -2];
c{iCond}.(sn).appearTau = 1;
c{iCond}.(sn).maxContrast = 0.3;
c{iCond}.(sn).radius = 1;
c{iCond}.(sn).onLifetime  = 120;
c{iCond}.(sn).offLifetime = 240;
% if type is 'grating', these parameters will be used
c{iCond}.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
    'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
% --- modules
c{iCond}.natImgBackground.use        = false;
c{iCond}.natImgBackground.on         = false;
c{iCond}.gaussianNoiseBlobs.use      = false;
c{iCond}.hartley.use                 = true;
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
c{iCond}.(sn).onLifetime  = ceil(2 * 120);
c{iCond}.(sn).offLifetime = ceil(3 * 120);
% --- modules
c{iCond}.natImgBackground.use   = true;
c{iCond}.natImgBackground.on    = true;
c{iCond}.gaussianNoiseBlobs.use = false;
c{iCond}.hartley.use            = false;
c{iCond}.csdFlash.use           = false;

%% --- Condition 3: Frozen Seed of Hartley
sn  = 'stimulus';
iCond = 3;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN       = 2;  % number of face objects
c{iCond}.(sn).minSpeed   = 3;  % minumum speed of face objects
c{iCond}.(sn).maxSpeed   = 8;
c{iCond}.(sn).motionType = 'randomwalk'; % randomwalk or linear
c{iCond}.(sn).type       = 'face';       % face or grating
c{iCond}.(sn).appearGazeContingent = false;
c{iCond}.(sn).appearRangePar = 2;
c{iCond}.(sn).appearCenter = [0 -2];
c{iCond}.(sn).appearTau = 1;
c{iCond}.(sn).maxContrast = 0.3;
c{iCond}.(sn).radius = 1;
c{iCond}.(sn).onLifetime  = 120;
c{iCond}.(sn).offLifetime = 240;
% if type is 'grating', these parameters will be used
c{iCond}.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
    'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
% --- modules
c{iCond}.natImgBackground.use        = false;
c{iCond}.natImgBackground.on         = false;
c{iCond}.gaussianNoiseBlobs.use      = false;

c{iCond}.csdFlash.use                = false;

sn = 'hartley';
c{iCond}.(sn).use                 = true;

c{iCond}.(sn).rngs.conditionerRNG = RandStream('mt19937ar','Seed',15239487);
setupRNG=c{iCond}.(sn).rngs.conditionerRNG;

c{iCond}.(sn).setupRNG='frozenSequence';

c{iCond}.(sn).sequenceLength = 6*120;
c{iCond}.(sn).count = 1;
c{iCond}.(sn).maxFrames=10e3;
c{iCond}.(sn).kx=nan(c{iCond}.(sn).maxFrames, c{iCond}.(sn).count);
c{iCond}.(sn).ky=nan(c{iCond}.(sn).maxFrames, c{iCond}.(sn).count);
c{iCond}.(sn).on=zeros(c{iCond}.(sn).maxFrames,c{iCond}.(sn).count);
c{iCond}.(sn).phi=nan(c{iCond}.(sn).maxFrames,c{iCond}.(sn).count);
c{iCond}.(sn).tf=nan(c{iCond}.(sn).maxFrames,c{iCond}.(sn).count);


c{iCond}.(sn).kxs=sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);
c{iCond}.(sn).kys=sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);

on=ceil(exprnd(p.trial.(sn).OnDuration, c{iCond}.(sn).sequenceLength,1));
off=round(exprnd(p.trial.(sn).OffDuration, c{iCond}.(sn).sequenceLength,1));
maxDuration = 20;
on=min(on, maxDuration);
off=min(off, maxDuration);
step=on+off;
nUpdates=find(cumsum(step)>c{iCond}.(sn).sequenceLength,1);

[kxg, kyg, ktfg]=ndgrid(c{iCond}.(sn).kxs, c{iCond}.(sn).kys, p.trial.(sn).tfs);
gridIx=randi(setupRNG, numel(kxg), nUpdates, 1);
fr=0;
for iStim=1:nUpdates
    iFrames=fr+(1:on(iStim));
    c{iCond}.(sn).kx(iFrames)=kxg(gridIx(iStim));
    c{iCond}.(sn).ky(iFrames)=kyg(gridIx(iStim));
    c{iCond}.(sn).on(iFrames)=1;
    c{iCond}.(sn).tf(iFrames)=ktfg(gridIx(iStim));
    c{iCond}.(sn).phi(iFrames)=rand*2*pi;
    fr=iFrames(end)+off(iStim)-1;
end

nRepeats = ceil(c{iCond}.(sn).maxFrames / c{iCond}.(sn).sequenceLength);
inds = 1:c{iCond}.(sn).sequenceLength;
c{iCond}.(sn).kx = repmat(c{iCond}.(sn).kx(inds,:), nRepeats, 1);
c{iCond}.(sn).ky = repmat(c{iCond}.(sn).ky(inds,:), nRepeats, 1);
c{iCond}.(sn).on = repmat(c{iCond}.(sn).on(inds,:), nRepeats, 1);
c{iCond}.(sn).tf = repmat(c{iCond}.(sn).tf(inds,:), nRepeats, 1);
c{iCond}.(sn).phi = repmat(c{iCond}.(sn).phi(inds,:), nRepeats, 1);


%%
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
