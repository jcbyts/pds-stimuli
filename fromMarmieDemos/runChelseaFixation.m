sca

clear settingsStruct
Screen('Preference','ScreenToHead', 1,0,0);

subject = 'Ellie';
rewardAmount  = .05;
noiseContrast = 0.3;

% add modular trial functions
settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
settingsStruct.behavior.reward.defaultAmount=rewardAmount;
settingsStruct.stimulus.rewardLevels = [.2 .4 .8 1 1.2 1.4];

settingsStruct.eyelink.use=true;
settingsStruct.eyelink.useRawData= true;

if strcmp(subject, 'jnk')
    settingsStruct.eyelink.use=false;
    settingsStruct.eyelink.useRawData= false;
    settingsStruct.mouse.useAsEyepos = true;
end

try
cm = getpref('marmoview_calibration', subject);
if ~isempty(cm)
    settingsStruct.eyelink.calibration_matrix = permute(cm, [2 1 3]);
end
end

%--------------------------------------------------------------------------
% Add csd module
sn='csdFlash';
settingsStruct.(sn).stateFunction.name='v1mapping.csdFlash';
settingsStruct.(sn).use=false;
settingsStruct.(sn).stateFunction.acceptsLocationInput=false;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;


%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name='v1mapping.natImgBackground';
settingsStruct.(sn).use=false;
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
% Sparse noise
sn='sparseNoise';
settingsStruct.(sn).stateFunction.name='v1mapping.sparseNoise';
settingsStruct.(sn).use=true;
settingsStruct.(sn).stateFunction.acceptsLocationInput=false;
settingsStruct.(sn).stateFunction.order=1;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).contrast = noiseContrast;
settingsStruct.(sn).gazeContingent = false;
settingsStruct.(sn).xy = [1920 1080]/2;
settingsStruct.(sn).pxsize = 20;
settingsStruct.(sn).size = [20 20];

settingsStruct.datapixx.use=true;
settingsStruct.datapixx.LogOnsetTimestampLevel=0;
settingsStruct.display.useOverlay=2;
settingsStruct.display.switchOverlayCLUTs=0;
settingsStruct.pldaps.pause.preExperiment=true;

%--- Chelsea specific fixation parameters
% settingsStruct.stimulus.fixWinRadius = 1.5;
% settingsStruct.stimulus.fixPointRadius = .3;
settingStruct.stimulus.rewardLevels = [0.1 0.2 0.4 0.8 1.0 1.2 1.4 1.7 2.0];
p=pldaps(@stimuli.fixflash.defaultParameters, subject, settingsStruct); p.run