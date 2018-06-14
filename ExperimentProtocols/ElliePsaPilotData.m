subject = 'Ellie'; %'test'
pauseBeforeExperiment = false;

%% Natural Image Free View: warm up

p = runNaturalImageFreeView('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imgDir', getpref('pep', 'colonyPics')); %#ok<*NASGU>


%% Face Forage with CSD

p = runFaceForageCSD('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'onDuration', 50, ...
    'offDuration', 150, ...
	'imgDir', getpref('pep', 'colonyPics'), ...
    'imageEveryNTrials', 10);

%% Face Forage with Hartley
p = runFaceForageHartley('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imageEveryNTrials', 15, ...
    'autoCorr', 'pBlank');

%% Face Forage with Hartley
p = runFaceForageHartley('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imageEveryNTrials', 15, ...
    'autoCorr', 'pBlank');

pds.plotTiming(p)

%% Fixation with spatial mapping

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 2; % number of squares on each frame
spatialSquaresOpts.lifetime = 2; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrpees) 
% spatialSquaresOpts.size = .25;
spatialSquaresOpts.position = [-5 5 5 -5]; % stimulus rect (in degrees) 
spatialSquaresOpts.size = .5;
spatialSquaresOpts.contrast = .75;

p = runFixFlashSpatialMap('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 60, ...
    'fixationPoint', 'bullseye');


%% Face Forage with spatial mapping

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 4; % number of squares on each frame
spatialSquaresOpts.lifetime = 2; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrpees) 
% spatialSquaresOpts.size = .25;
spatialSquaresOpts.position = [-15 15 15 -15]; % stimulus rect (in degrees) 
spatialSquaresOpts.size = 1;
spatialSquaresOpts.contrast = .75;

p = runFaceForageSpatialMapping('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 10);

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


