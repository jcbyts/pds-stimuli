% This protocol tests the fixationImg class that is found in
% +stimuli/fixationImg

% Additionally, it can be used as a model for testing other stimulus
% protocols

% --- setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files

settingsStruct.display.normalizeColor = 1;
settingsStruct.display.colorclamp = 1;
% 
settingsStruct.display.destinationFactorNew = GL_ONE;
settingsStruct.display.sourceFactorNew = GL_ONE;

settingsStruct.display.useOverlay = 1;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% make everything bigger (viewdist scales the pixels per degree
% calculation)
settingsStruct.pldaps.pause.preExperiment = false;

%% add module to test
sn = 'calibration';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.calibration.basicGrid';
settingsStruct.(sn).stateFunction.order = 2;    % when to run this module with respect to other modules
settingsStruct.(sn).use                 = true; % use this module    
settingsStruct.(sn).shrinkTimeConstant = .1;
settingsStruct.(sn).onRate = 1e-3;
% calling pldaps with @stimuli.pldapsDefaultTrial will make sure that
% pldaps takes all the measurements that are required for our modules
% (e.g., eye position)
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p = p.run;