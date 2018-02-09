
subject = 'Jude';
pauseBeforeExperiment = true;

%% Natural Image Free View: warm up

runNaturalImageFreeView('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imgDir', getpref('pep', 'colonyPics'))


%% Face Forage with CSD

runFaceForageCSD('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'onDuration', 50, ...
    'offDuration', 150, ...
	'imgDir', getpref('pep', 'colonyPics'), ...
    'imageEveryNTrials', 5);

%% Face Forage with Hartley

%% Fixation with spatial mapping

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 2; % number of squares on each frame
spatialSquaresOpts.lifetime = 2; % lifetime of squares frames
spatialSquaresOpts.position = [0 0 5 -5]; % stimulus rect (in degrees) 
spatialSquaresOpts.lifetime = 2;
spatialSquaresOpts.size = .5;

runFixFlashSpatialMap('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts)

%% 
runGaborTargetSelection('subject', subject,...
    'pauseBefore', pauseBeforeExperiment)

