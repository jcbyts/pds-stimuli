subject = 'test';% 'Ellie'; %'test'
pauseBeforeExperiment = false;

settingsStruct = struct();

%% if using digital dual purkinje eye tracker pilot
% sn = 'ddpi';
% settingsStruct.(sn).stateFunction.name = 'stimuli.modules.ddpi.ddpi';
% settingsStruct.(sn).stateFunction.order = -3;
% settingsStruct.(sn).use = true;

%% Natural Image Free View: warm up

p = runNaturalImageFreeView('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imgDir', getpref('pep', 'colonyPics'), ...
    'settingsStruct', settingsStruct);


%% Face Forage with CSD

p = runFaceForageCSD('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'onDuration', 50, ...
    'offDuration', 150, ...
	'imgDir', getpref('pep', 'colonyPics'), ...
    'imageEveryNTrials', 10, ...
    'settingsStruct', settingsStruct);

%% Face Forage with Hartley
p = runFaceForageHartley('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imageEveryNTrials', 15, ...
    'autoCorr', 'pBlank', ...
    'settingsStruct', settingsStruct);

%% Face Forage with Hartley
p = runFaceForageHartley('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imageEveryNTrials', 15, ...
    'autoCorr', 'pBlank', ...
    'settingsStruct', settingsStruct);

pds.plotTiming(p)

%% Fixation with spatial mappingp
spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 4; % number of squares on each frame
spatialSquaresOpts.lifetime = 8; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrpees) 
% spatialSquaresOpts.size = .25;
spatialSquaresOpts.position = [-5 5 5 -5]; % stimulus rect (in degrees) 
spatialSquaresOpts.size = .5;
spatialSquaresOpts.contrast = .75;

p = runFixFlashSpatialMap('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 50, ...
    'fixationPoint', 'bullseye', ...
    'staircaseFixation', true, ...
    'settingsStruct', settingsStruct);


%% Face Forage with spatial mapping

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 10; % number of squares on each frame
spatialSquaresOpts.lifetime = 8; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrpees) 
% spatialSquaresOpts.size = .25;
spatialSquaresOpts.position = [-20 20 20 -20]; % stimulus rect (in degrees) 
spatialSquaresOpts.size = 1;
spatialSquaresOpts.contrast = 1;

p = runFaceForageSpatialMapping('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 10, ...
    'settingsStruct', settingsStruct);

%% Presaccadic selection with gabors
SingleTarget = 0;
runGaborTargetSelection('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,'SingleTarget', SingleTarget)


%% Full field direction mapping
p = runFaceForageDirectionMapping('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imageEveryNTrials', 15);

%% add module to test


% calling pldaps with @stimuli.pldapsDefaultTrial will make sure that
% pldaps takes all the measurements that are required for our modules
% (e.g., eye position)
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p = p.run;


