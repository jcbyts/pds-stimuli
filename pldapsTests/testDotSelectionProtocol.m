
%% Test 1: Dot selection Basics

% setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files

% set blend function appropriately
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% make everything bigger (viewdist scales the pixels per degree
% calculation)
settingsStruct.display.viewdist = 100; % cm

% dot selection requires a fixation behavior
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.order = 1;
settingsStruct.(sn).use = true;

settingsStruct.(sn).staircaseOn    = false;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;
settingsStruct.(sn).showGUI = false;

sn = 'dotselection';
% settingsStruct.(sn).stateFunction.name = 'stimuli.modules.dotselection.runDefaultTrial';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.dotselection.runGaborsTrial';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

settingsStruct.(sn).fixationBehavior = 'fixflash'; % pointer to the fixation behavior
settingsStruct.(sn).staircaseOn = true;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;

% run pldaps
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run