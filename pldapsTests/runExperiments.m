%% Sample experiments

subject = 'test';
pauseBeforeExperiment = 0;


%% Free View Natural Images

runNaturalImageFreeView

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

%% MT mapping 2: Dot motion
runFaceForageDotMapping(subject, pauseBeforeExperiment)