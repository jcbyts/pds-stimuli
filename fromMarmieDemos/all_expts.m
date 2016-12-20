
%% create settingsstruct
% %% add openephys
settingsStruct.openephys.stateFunction.name='pds.openephys.openephys';
settingsStruct.openephys.use=true;
settingsStruct.openephys.stateFunction.acceptsLocationInput=true;
settingsStruct.openephys.stateFunction.order=0;
settingsStruct.openephys.stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.openephys.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.openephys.stateFunction.requestedStates.trialSetup=true;
settingsStruct.openephys.stateFunction.requestedStates.trialCleanUpandSave=true;
% settingsStruct.pldaps.useModularStateFunctions = true;
% settingsStruct.pldaps.trialMasterFunction='runModularTrial';
% settingsStruct.newEraSyringePump.use=false;
%% add touchReward
settingsStruct.touchreward.stateFunction.name='touchReward';
settingsStruct.touchreward.use=true;
settingsStruct.touchreward.stateFunction.acceptsLocationInput=true;
settingsStruct.touchreward.stateFunction.order=-5;
settingsStruct.touchreward.stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.openephys.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.touchreward.stateFunction.requestedStates.trialSetup=true;
settingsStruct.touchreward.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.touchreward.stateFunction.requestedStates.framePrepareDrawing=true;


%% add eye marker (press e)
settingsStruct.eyemarker.stateFunction.name='rawEyeMarker';
settingsStruct.eyemarker.use=false;
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
% subject='test';
subject='jo';
% subject='hardy';

if strcmp(subject,'test')
    settingsStruct.eyelink.use=false
    settingsStruct.mouse.useAsEyepos=true
end
% settingsStruct.pldaps.useModularStateFunctions = true;
% settingsStruct.pldaps.trialMasterFunction='runModularTrial';
% settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
settingsStruct.behavior.reward.defaultAmount=.030;
settingsStruct.display.bgColor=[0.7 0.7 0.7];

%% calibrationscript demo
% settingsStruct.eyelink.use=false
% settingsStruct.mouse.useAsEyepos=true
% settingsStruct.eyemarker.use=true;
% calibrationScript
p=pldaps(@gta.setup.faceGrid,subject, settingsStruct);
p.trial.eyemarker.use=true;
% p.trial.pldaps.experimentAfterTrialsFunction=[];
p.run
%check why filesize is large

%% fixation trianing
% settingsStruct.eyemarker.use=true;
p=pldaps(@fixationTraining,settingsStruct);
p.trial.eyemarker.use=true;
% p.trial.eyelink.use=false;
% p.trial.mouse.useAsEyepos=true;
p.trial.eyemarker.refineCalibratrionFromWindow = true;
p.trial.eyemarker.drawStims = false;
p.run

%% opticflow
% settingsStruct.eyemarker.use=false;
p=pldaps(@opticflow.flow120HzDegContingentMaskViewPixxTrain, subject);
% p.trial.eyelink.use=false;
% p.trial.mouse.useAsEyepos=true;
% p.trial.display.bgColor=[0.7 0.7 0.7];
p.trial.pldaps.experimentAfterTrialsFunction='opticflowPostTrial';
p.run

%% rashbass training
p=pldaps(@rashbassTextures, settingsStruct);
p.trial.plot.use=true;
p.trial.eyemarker.use=false;
p.trial.behavior.reward.defaultAmount=.025;
p.run

%% pursuit2 trianing
p=pldaps(@pursuitTraining2,settingsStruct);
% p.trial.eyelink.use=false;
% p.trial.mouse.useAsEyepos=true;
% p.trial.newEraSyringePump.use=false;
p.trial.behavior.reward.defaultAmount=25;
p.trial.eyemarker.refineCalibratrionFromWindow = false;
p.trial.eyemarker.drawStims = false;
p.trial.plot.use=false;
p.trial.eyemarker.use=false;
p.run



%% pursuit trianing
p=pldaps(@pursuitTraining,settingsStruct);
% p.trial.eyelink.use=false;
% p.trial.mouse.useAsEyepos=true;
p.trial.eyemarker.refineCalibratrionFromWindow = false;
p.trial.eyemarker.drawStims = false;
p.trial.plot.use=false;
p.trial.eyemarker.use=false;
p.run


%% FP Motion
p=pldaps(@fpmotionFixation,subject,settingsStruct);
p.run
%% Kreisreiz
p=pldaps(@kreisreizFixation,subject,settingsStruct);
p.run

%% %Mapping
p=pldaps(@fpmotionMapping,subject,settingsStruct);
p.run






%% calibrationscript full
calibrationScript
p.run


%%
p=pldaps(@rashbassTextures,'test');
p.run

%%
p=pldaps(@dualRashbassTextures,'test');
p.run

%%
% %add openephys
settingsStruct.openephys.stateFunction.name='pds.openephys.openephys';
settingsStruct.openephys.use=true;
settingsStruct.openephys.stateFunction.acceptsLocationInput=true;
settingsStruct.openephys.stateFunction.order=0;
settingsStruct.openephys.stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.openephys.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.openephys.stateFunction.requestedStates.trialSetup=true;
settingsStruct.openephys.stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.newEraSyringePump.use=false;
%%
p=pldaps(@kreisreizFixation,subject,settingsStruct);
p.trial.eyelink.useRawData=true;
p.trial.pldaps.pause.preExperiment=false;
p.trial.eyelink.calibration_matrix=zeros(2,3,2);
load /Users/huklab/casual/b2_201606211315.mat
b3=b2;

p.trial.eyelink.calibration_matrix(:,:,1)=b3';
p.trial.eyelink.calibration_matrix(:,:,2)=b3';
p.trial.eyelink.use=true;
p.trial.eyelink.useAsEyepos=true;

p.trial.mouse.useAsEyepos=false;
p.run


%%
p=pldaps(@hyperflowFixation,'test');
p.run