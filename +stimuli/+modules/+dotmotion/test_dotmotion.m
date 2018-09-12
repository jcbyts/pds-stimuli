% Script for testing the default arguments / trialSetup
sca 

% --- setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% dot selection requires a fixation behavior
sn = 'dotmotion';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.dotmotion.runTrial';
settingsStruct.(sn).stateFunction.order = 1;
settingsStruct.(sn).use = true;

% optional arguments
settingsStruct.(sn).motion.speed = 10;
settingsStruct.(sn).motion.radius   = 4;
settingsStruct.(sn).fixation.radius = 1;

settingsStruct.display.normalizeColor = 1;
settingsStruct.pldaps.pause.preExperiment = 0;

settingsStruct.session.subject = 'Mouse';

settingsStruct = loadCalibration(settingsStruct);

p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run


