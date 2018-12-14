% This protocol tests the fixationImg class that is found in
% +stimuli/fixationImg

% Additionally, it can be used as a model for testing other stimulus
% protocols

% --- setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.session.subject = 'test';

settingsStruct.pldaps.nosave = false; % don't save any files
% 
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;

settingsStruct.display.useOverlay = 1;

% make everything bigger (viewdist scales the pixels per degree
% calculation)
settingsStruct.pldaps.pause.preExperiment = false;
settingsStruct.pldaps.maxTrialLength = 10;

%% add module to test
sn = 'HDmovies';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.HDmovies';
settingsStruct.(sn).stateFunction.order = 1;    % when to run this module with respect to other modules
settingsStruct.(sn).use                 = true; % use this module
% calling pldaps with @stimuli.pldapsDefaultTrial will make sure that
% pldaps takes all the measurements that are required for our modules
% (e.g., eye position)

settingsStruct = loadCalibration(settingsStruct);

p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p = p.run;