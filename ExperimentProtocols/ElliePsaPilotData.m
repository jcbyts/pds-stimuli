subject = 'Ellie'; %'Ellie'; %'test'
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

%% Fixation with spatial mapping

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 2; % number of squares on each frame
spatialSquaresOpts.lifetime = 2; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrees) 
% spatialSquaresOpts.size = .5;
spatialSquaresOpts.position = [-5 5 5 -5]; % stimulus rect (in degrees) 
spatialSquaresOpts.size = .5;
spatialSquaresOpts.contrast = .65;

p = runFixFlashSpatialMap('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 60, ...
    'fixationPoint', 'bullseye');

%% Presaccadic selection with gabors
SingleTarget = 0;
runGaborTargetSelection('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,'SingleTarget', SingleTarget)

