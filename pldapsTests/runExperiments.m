%% Sample experiments

subject = 'test';
pauseBeforeExperiment = 0;


%% Free View Natural Images

runNaturalImageFreeView(subject, pauseBeforeExperiment)

%% Fix Flash With Gaussian Pyramid Noise

runFixFlashWithGaussianPyrNoise(subject, pauseBeforeExperiment);

%% Fix Flash With Hartley

runFixFlashWithHartley(subject, pauseBeforeExperiment)

%% Fix Flash With White Noise

runFixFlashWithSparseNoise(subject, pauseBeforeExperiment);

%% Face Forage With Gaussian Pyramid Noise

runFaceForageGaussianPyrNoise(subject, pauseBeforeExperiment);

%% Face Forage with Hartley

runFaceForageHartley(subject, pauseBeforeExperiment);

%% Face Forage with CSD flash
runFaceForageCSD(subject, pauseBeforeExperiment);


%% MT mapping 1: Fix Flash with dot motion
runFaceForageDotMapping(subject, pauseBeforeExperiment, ...
    'speed', 10, ...
    'apertureSize', 5, ...
    'onDuration', 60, ...  % in frames
    'offDuration', 0, ... % in frames
    'numDirections', 12, ...
    'gazeContingent', 10, ...
    'task', 'fixflash', ...
    'dotx', 5, ...
    'doty', -5, ...
    'randomizeDirections', false);
%% MT mapping 2: Dot motion 
runFaceForageDotMapping(subject, pauseBeforeExperiment, ...
    'speed', 10, ...
    'apertureSize', 20, ...
    'onDuration', 60, ...  % in frames
    'offDuration', 0, ... % in frames
    'numDirections', 12, ...
    'gazeContingent', 10, ...
    'task', 'oddball', ...
    'dotx', 5, ...
    'doty', 5, ...
    'randomizeDirections', false);
