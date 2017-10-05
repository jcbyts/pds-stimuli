function runFixFlashWithGaussianPyrNoise(subject, pauseBeforeStart)

if nargin < 2
    pauseBeforeStart = true;
    if nargin < 1
        subject = 'Ellie';
    end
end


% --- parameters for the gaussian pyramid noise stimulus
gaussianContrast = .3;
gaussianSigma    = 0.25;
numInBaseLevel   = 50;   % number in the base level
numLevels        = 1;    % number of levels (should be 1!!)
fixWinRadius     = 1.5;  % fixation window radius (degrees)
fixPointRadius   = .3;
rewardAmount     = 0.075; %.05; % ul? syringe pump uncalibrated

%--------------------------------------------------------------------------
% --- Setup PLDAPS
behavior = @stimuli.fixflash.defaultParameters;
showCSDFlash       = false;
showNatBackground  = false;
showGaussNoise     = false;
showHartleyStimuli = false;
showGaussianBlobs  = true;

settingsStruct = struct();
settingsStruct.display.destinationFactorNew = GL_ONE;
settingsStruct.display.sourceFactorNew = GL_ONE;
settingsStruct.display.colorclamp     = 1;
settingsStruct.display.normalizeColor = 1;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount = rewardAmount;

settingsStruct.session.subject=subject;

settingsStruct.stimulus.fixWinRadius   = fixWinRadius;
settingsStruct.stimulus.fixPointRadius = fixPointRadius;

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
settingsStruct.(sn).onDuration = 50;
settingsStruct.(sn).offDuration = 150;
settingsStruct.(sn).onColor = 1;
settingsStruct.(sn).offColor = .5;

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
% Add Gaussian Pyramid Noise
sn='gaussPyrNoise';
settingsStruct.(sn).stateFunction.name='v1mapping.gaussPyrNoise';
settingsStruct.(sn).use=showGaussNoise;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;


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
% settingsStruct.(sn).OnDuration=2;
% settingsStruct.(sn).OffDuration=4;
% settingsStruct.(sn).contrast=.25;
% settingsStruct.(sn).Freq0=.025;
% settingsStruct.(sn).nOctaves=5;
% settingsStruct.(sn).tfs=0;
% settingsStruct.(sn).sfscale=1;

settingsStruct.hartley.OnDuration     = 2;
settingsStruct.hartley.OffDuration    = 4;       
settingsStruct.hartley.contrast       = .15;
settingsStruct.hartley.tfs            = 0; %[0 2 4 8 16];
settingsStruct.hartley.sfscale        = 1;
settingsStruct.hartley.nOctaves       = 5;
settingsStruct.hartley.Freq0          =.5;


%--------------------------------------------------------------------------
% Add gaussian blob noise
sn='gaussianNoiseBlobs';
settingsStruct.(sn).stateFunction.name='v1mapping.gaussianNoiseBlobs';
settingsStruct.(sn).use=showGaussianBlobs;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).N        = numInBaseLevel; % number in the base level
settingsStruct.(sn).levels   = numLevels; % number of levels
settingsStruct.(sn).contrast = gaussianContrast;
settingsStruct.(sn).sigma0   = gaussianSigma;

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


% run pldaps
p = pldaps(behavior, settingsStruct);

p.run

return
