% Script for testing the default arguments / trialSetup

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
settingsStruct.(sn).motion.dotSpeed = 222;
settingsStruct.(sn).motion.radius   = 2;
settingsStruct.(sn).fixation.radius = 1;

p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.openScreen
%% test that the default arguments were overriden by the optional arguments

% test just the default parameters function
stimuli.modules.dotmotion.defaultParameters(p);
disp(p.trial.(sn).motion)

%% test experiment open screen
stimuli.setupDefaultFrameStates(p, sn)
p = stimuli.setupRandomSeed(p, sn);
        
p.trial = mergeToSingleStruct(p.trial);
state = p.trial.pldaps.trialStates.experimentPostOpenScreen;
p = feval(p.defaultParameters.dotmotion.stateFunction.name, p, state);

%% test trialSetup
state = p.trial.pldaps.trialStates.trialSetup;
p = feval(p.defaultParameters.dotmotion.stateFunction.name, p, state);


disp(p.trial.dotmotion.motion)


