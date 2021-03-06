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
% settingsStruct.display.viewdist = 100; % cm


sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

settingsStruct.(sn).staircaseOn = true;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0.008;

sn = 'spatialSquares';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.spatialSquares';
settingsStruct.(sn).stateFunction.order = -1;
settingsStruct.(sn).use = true;
settingsStruct.(sn).N = 4;
settingsStruct.(sn).contrast = 1;
settingsStruct.(sn).size = .5;
settingsStruct.(sn).position = [0 0 5 -5];
settingsStruct.(sn).minFixation = .01;

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

settingsStruct.eyelink.use = false;
settingsStruct.mouse.use = true;
settingsStruct.mouse.useAsEyepos = true;

sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runImgScan';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
settingsStruct.(sn).staircaseOn = false;
settingsStruct.(sn).minFixDuration = 2;
settingsStruct.(sn).shrinkTimeConstant = .05;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;
% 
sn = 'spatialSquares';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.spatialSquares';
settingsStruct.(sn).stateFunction.order = 3;
settingsStruct.(sn).use = true;
settingsStruct.(sn).N = 4;
settingsStruct.(sn).contrast = 1;
settingsStruct.(sn).size = .5;
settingsStruct.(sn).position = [0 0 5 -5];
settingsStruct.(sn).minFixation = .01;

% run pldaps
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run