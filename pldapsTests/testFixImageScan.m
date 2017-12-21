% This protocol tests the fixationImg class that is found in
% +stimuli/fixationImg

% Additionally, it can be used as a model for testing other stimulus
% protocols

% --- setup pldaps and testing modules
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


%% add module to test
sn = 'testing';
settingsStruct.(sn).stateFunction.name  = 'stimuli.tests.testFixImgTrial';
settingsStruct.(sn).stateFunction.order = 2;    % when to run this module with respect to other modules
settingsStruct.(sn).use                 = true; % use this module    

% calling pldaps with @stimuli.pldapsDefaultTrial will make sure that
% pldaps takes all the measurements that are required for our modules
% (e.g., eye position)
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p = p.run;

% 
% %% -------------------------------------------------------------------------
% 
% 
% %%
% sn = 'fixflash';
% settingsStruct.(sn).stateFunction.name = 'stimuli.fixflash.runImgScan';
% settingsStruct.(sn).stateFunction.order = 2;
% settingsStruct.(sn).use = true;
% settingsStruct.(sn).staircaseOn = false;
% settingsStruct.(sn).minFixDuration = 2;
% settingsStruct.(sn).shrinkTimeConstant = 0;
% settingsStruct.(sn).fixationJitter = false;
% settingsStruct.(sn).fixationJitterSize = 0;
% 
% 
% 
% %% run pldaps
% p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);
% 
% p.run
% 
% 
% 
% 
% %%
% 
% s = stimuli.fixationImg;
% s.xyPix = p.trial.display.ctr(1:2);
% 
% 
% %% calibration protocol?
% s.radius = 15;
% % s.wincolor = p.trial.display.clut.greenbg;
% for j = 1:50
% s.xyPix = randn(1,2).*50 + p.trial.display.ctr(1:2);
% s.trialSetup(p)
% 
% for i = 1:40; s.frameUpdate(p); s.frameDraw(p); Screen('Flip', p.trial.display.ptr); end
% 
% end
% 
% %% fixation protocol
% s.radius = 25;
% s.xyPix = p.trial.display.ctr(1:2);
% s.trialSetup(p)
% 
% for i = 1:540; s.frameUpdate(p); s.frameDraw(p); Screen('Flip', p.trial.display.ptr); end
% Screen('Flip', p.trial.display.ptr);