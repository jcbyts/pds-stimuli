% This protocol tests the fixationImg class that is found in
% +stimuli/fixationImg

% Additionally, it can be used as a model for testing other stimulus
% protocols

%% Test 1: FixFlash Basics

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


sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
settingsStruct.(sn).staircaseOn = true;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;

% run pldaps
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run

%% Test 2: FixFlash with Image Scan

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


sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.fixflash.runImgScan';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
settingsStruct.(sn).staircaseOn = false;
settingsStruct.(sn).minFixDuration = 2;
settingsStruct.(sn).shrinkTimeConstant = 0;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;

% run pldaps
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run