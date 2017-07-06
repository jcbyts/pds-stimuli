function runFixFlashWithHartley(subject, pauseBeforeStart)

if nargin < 2
    pauseBeforeStart = true;
    if nargin < 1
        subject = 'Ellie';
    end
end


% --- parameters for the Hartley noise stimulus
OnDuration       = 2; % time constant on (frames)
OffDuration      = 4; % time constant off (frames)
hartleyContrast  = .15; % contrast of the gratings
nOctaves         = 5;   % number of octaves
Freq0            =.5;   % base spatial frequency
fixWinRadius     = 1.5;  % fixation window radius (degrees)
fixPointRadius   = .3;
rewardAmount     = .05; % ul? syringe pump uncalibrated

%--------------------------------------------------------------------------
% --- Setup PLDAPS
behavior = @stimuli.fixflash.defaultParameters;

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
% Add Hartley Stimulus
sn='hartley';
settingsStruct.(sn).stateFunction.name='v1mapping.hartleyStimuli';
settingsStruct.(sn).use=true;
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


% run pldaps
p = pldaps(behavior, settingsStruct);

p.run

return
