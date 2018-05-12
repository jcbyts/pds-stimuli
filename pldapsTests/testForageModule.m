% This protocol tests the fixationImg class that is found in
% +stimuli/fixationImg

% Additionally, it can be used as a model for testing other stimulus
% protocols

%% Test 1: FixFlash Basics

% setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files

% set blend function appropriately
% settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
% settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;

settingsStruct.display.destinationFactorNew = GL_ONE;
settingsStruct.display.sourceFactorNew = GL_ONE;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% make everything bigger (viewdist scales the pixels per degree
% calculation)
settingsStruct.display.viewdist = 100; % cm

sn = 'csdFlash';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.csd.basicFlash';
settingsStruct.(sn).stateFunction.order = -1; % draw before behavior
settingsStruct.(sn).use = false;

sn = 'hartley';
% settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.hartley.defaultHartleyTrial';
% settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.hartley.hartleyTrialGazeContingentUpdating';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.hartley.gratingTrialGazeContingentUpdating';
settingsStruct.(sn).stateFunction.order = -1; % draw before behavior
settingsStruct.(sn).use = false;
settingsStruct.(sn).pBlank = .5;

% sn = 'dotmapping';
% settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.DotApertureMapping';
% settingsStruct.(sn).stateFunction.order = -1; % draw before behavior
% settingsStruct.(sn).use = true;

sn = 'MotionMapping';
settingsStruct.pldaps.nosave = true; % don't save any files

% settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.DotMotionMapping';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.DotsFullFieldDirectionMapping';
settingsStruct.(sn).stateFunction.order = 2;    % when to run this module with respect to other modules
settingsStruct.(sn).use                 = true; % use this module    
settingsStruct.(sn).onDuration = 20;
settingsStruct.(sn).offDuration = 50;
settingsStruct.(sn).dotContrast = -.05;

sn = 'spatialSquares';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.spatialSquares';
settingsStruct.(sn).stateFunction.order = -1; % draw before behavior
settingsStruct.(sn).use = false;
settingsStruct.(sn).N = 4;
settingsStruct.(sn).contrast = 1;
settingsStruct.(sn).size = 1;
settingsStruct.(sn).position = [-5 5 5 -5];
settingsStruct.(sn).minFixation = nan;

sn = 'forage';
% settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.forage.forage';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
settingsStruct.(sn).maxContrast = 1;
% settingsStruct.(sn).staircaseOn = true;
% settingsStruct.(sn).minFixDuration = .2;
% settingsStruct.(sn).fixationJitter = false;
% settingsStruct.(sn).fixationJitterSize = 0;

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
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runImgScan';
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