
clear settingsStruct
settingsStruct.stimulus.gratingContrast = .15;

% settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
% settingsStruct.pldaps.save.mergedData=0;

sn='natImgBackground';
settingsStruct.(sn).stateFunction.name='v1mapping.natImgBackground';
settingsStruct.(sn).use=true;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;

p=pldaps(@stimuli.gratingForage.defaultParameters, 'jude', settingsStruct); p.run