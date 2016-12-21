
subject='test';
settingsStruct.behavior.reward.defaultAmount=.05;
settingsStruct.display.destinationFactorNew=GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew=GL_SRC_ALPHA;
settingsStruct.pldaps.pause.type=1;

settingsStruct.eyelink.useRawData=true;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;

sc='calibration';
settingsStruct.(sc).stateFunction.name='marmoview_FaceCal';
settingsStruct.(sc).use=true;
settingsStruct.(sc).stateFunction.acceptsLocationInput=true;
settingsStruct.(sc).stateFunction.order=-5;
settingsStruct.(sc).stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.(sc).stateFunction.requestedStates.experimentPreOpenScreen=true;
% settingsStruct.(sc).stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sc).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.(sc).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sc).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sc).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sc).stateFunction.requestedStates.trialCleanUpandSave=true;

p=pldaps(@marmoviewCalibrationGrid,subject, settingsStruct);
%  p=pldaps(@gta.setup.dotGrid,subject, settingsStruct);
p = defaultBitNames(p);
%  p.trial.pldaps.useModularStateFunctions = true;
p.trial.pldaps.experimentAfterTrialsFunction=[];
p.trial.pldaps.pause.preExperiment=false;
p.run
%%

% p.trial.pldaps.experimentAfterTrialsFunction='gta.analysis.calibrationPostTrial';


% if input('Overwrite Sawyer Calibration (1 or 0)?')
%     subject='Sawyer';
%     load ~/Settings/sawyerSettingStruct.mat
%     settingsStruct.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx) = p.data{end}.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx);
%     save('~/Settings/sawyerSettingStruct.mat', 'subject', 'settingsStruct')
% end

settingsStruct.eyemarker.stateFunction.name='rawEyeMarker';
settingsStruct.eyemarker.use=true;
settingsStruct.eyemarker.stateFunction.acceptsLocationInput=true;
settingsStruct.eyemarker.stateFunction.order=-5;
settingsStruct.eyemarker.stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.eyemarker.stateFunction.requestedStates.experimentPreOpenScreen=true;
settingsStruct.eyemarker.stateFunction.requestedStates.trialSetup=true;
settingsStruct.eyemarker.stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.eyemarker.stateFunction.requestedStates.frameDraw=true;
settingsStruct.eyemarker.stateFunction.requestedStates.trialCleanUpandSave=true;

p=pldaps(@fixationTraining,subject,settingsStruct);

p.trial.eyemarker.refineCalibratrionFromWindow = true;
p.trial.pldaps.pause.preExperiment=false;
p.trial.eyemarker.drawStims = false;
p.run