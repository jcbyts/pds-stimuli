sca
clear
Screen('Preference','ScreenToHead', 1,0,0);
%% Calibrate the Eye
SawyerFaceCal


%% fixation training
Screen('Preference','ScreenToHead', 1,0,0);
settingsStruct.eyemarker.use=false;
p=pldaps(@fixationTrainingNoise,settingsStruct);

p.run

%% fixation training
Screen('Preference','ScreenToHead', 1,0,0);

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
settingsStruct.behavior.reward.defaultAmount=.1;
settingsStruct.eyemarker.use=false;

%%

%% add target trace plot
settingsStruct.plot.stateFunction.name='gtaTracePlot';
settingsStruct.plot.use=true;
settingsStruct.plot.stateFunction.acceptsLocationInput=true;
settingsStruct.plot.stateFunction.order=Inf;
% settingsStruct.plot.stateFunction.requestedStates.experimentPreOpenScreen=true;
settingsStruct.plot.stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.plot.stateFunction.requestedStates.experimentCleanUp=true;
% settingsStruct.plot.stateFunction.requestedStates.trialSetup=true;
% settingsStruct.plot.stateFunction.requestedStates.frameUpdate=true;
% settingsStruct.plot.stateFunction.requestedStates.framePrepareDrawing=true;
% settingsStruct.plot.stateFunction.requestedStates.frameDraw=true;
settingsStruct.plot.stateFunction.requestedStates.trialCleanUpandSave=true;


%%
p=pldaps(@delayedsaccadesNoise, subject, settingsStruct);
p.run


%% visually guided saccades
Screen('Preference','ScreenToHead', 1,0,0);


settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
settingsStruct.behavior.reward.defaultAmount=.1;

p=pldaps(@delayedsaccades, subject, settingsStruct);
p.run

%% screen saver fun
Screen('Preference','ScreenToHead', 1,0,0);
try  %#ok<TRYNC>
    PsychPortAudio('Close', 0);
end

settingsStruct.behavior.reward.defaultAmount=.05;

settingsStruct.eyelink.useRawData=true;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
 
settingsStruct.eyemarker.stateFunction.name='judeStyleEyeCalibration';
settingsStruct.eyemarker.use=true;
settingsStruct.eyemarker.stateFunction.acceptsLocationInput=true;
settingsStruct.eyemarker.stateFunction.order=-5;
settingsStruct.eyemarker.stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.eyemarker.stateFunction.requestedStates.experimentPreOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.eyemarker.stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.eyemarker.stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.eyemarker.stateFunction.requestedStates.frameDraw=true;
settingsStruct.eyemarker.stateFunction.requestedStates.trialCleanUpandSave=true;

settingsStruct.screensaver.stateFunction.name='screenSaverTrial';
settingsStruct.screensaver.use=false;
settingsStruct.screensaver.stateFunction.acceptsLocationInput=true;
settingsStruct.screensaver.stateFunction.order=-6;
settingsStruct.screensaver.stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.screensaver.stateFunction.requestedStates.experimentPreOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.screensaver.stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.screensaver.stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.screensaver.stateFunction.requestedStates.frameDraw=true;
% settingsStruct.screensaver.stateFunction.requestedStates.trialCleanUpandSave=true;

p=pldaps(@marmoviewCalibrationGrid,subject, settingsStruct);
%  p=pldaps(@gta.setup.dotGrid,subject, settingsStruct);
p = defaultBitNames(p);
%  p.trial.pldaps.useModularStateFunctions = true;
p.trial.pldaps.experimentAfterTrialsFunction=[];
% p.trial.pldaps.trialMasterFunction='runModularTrial';
% p.trial.eyelink.useRawData=true;
p.trial.pldaps.pause.preExperiment=false;
%p.run






%%
p=pldaps(@screenSaverTrial2, 'test'); p.run