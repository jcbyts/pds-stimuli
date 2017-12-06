%% Sample experiments

subject = 'Ellie'; % Ellie (Capitalized)
pauseBeforeExperiment = 0;

%% Test subject case
subject = 'test'; 
pauseBeforeExperiment = 0;

%% Free View Natural Images
runNaturalImageFreeView(subject, pauseBeforeExperiment);

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

%% MT mapping: Dot motion (don't need to run)
runFaceForageDotMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [15], ... % degrees/sec
    'apertureSize', 4, ...       % degrees
    'dotContrast', .1, ...      % ~Michelson contrast
    'onDuration', 12, ...  % in frames
    'offDuration', 1, ... % in frames
    'numDirections', 12, ...% 
    'gazeContingent', false, ...
    'holdDuration', 15, ... % frames
    'task', 'faceforage', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', true);
   % 'task', 'fixflash', ... % oddball, faceinvaders, fixflash
   % 'randomizeDirections', true);

%% Motion saccade task

% edit this function to see how it works (I will add parameter arguments
% later)--Jake
runDotSelection(subject, pauseBeforeExperiment)

%% Spatial Mapping (Range, Fixation)
runSpatialMapping(subject, pauseBeforeExperiment, ...
    'lifetime', 4, ...       % frames
    'N', 1, ... % # of squares
    'size', .5, ...       % degrees
    'task', 'fixflash', ... %'faceforage', ... % oddball, faceinvaders, fixflash
    'position', [0 0 5 -5], ... % degrees X,Y,X,Y Upper-Left, Bottom-Right (relative to center of screen)
    'contrast', .5, ...
    'targetSpeed', 2, ...       % degrees/sec
    'onDuration', 30, ...  % in frames
    'offDuration',48);

%% Spatial Mapping (Full field, Free View)
runSpatialMapping(subject, pauseBeforeExperiment, ...
    'lifetime', 3, ...       % degrees/sec
    'N', 4, ... % degrees/sec
    'size', 2, ...       % degrees
    'task', 'faceforage', ... %'faceforage', ... % oddball, faceinvaders, fixflash
    'contrast', .5, ...
    'targetSpeed', 2, ...       % degrees/sec
    'onDuration', 30, ...  % in frames
    'offDuration',48); 

%% Decoding stimulus: limited range (this one first)
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'priorMu', 60, ...
    'priorKappa', 10, ...% Kappa parameter of von Mises is uniform if == 0, gets narrower as you increase
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [10, 10, 10, 10], ... % degrees/sec
    'apertureSize', 20, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast
    'onDuration', 36, ...  % in frames
    'offDuration',60, ... % in frames
    'numDirections',50, ... m
    'gazeContingent', false, ...
    'holdDuration', 30, ... % frames
    'task', 'faceforage', ... %'faceforage', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', true); % step through directions clockwise or counter
%% Decoding stimulus: full range (this one second)
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'priorMu', 0, ...
    'priorKappa', 0, ...% Kappa parameter of von Mises is uniform if == 0, gets narrower as you increase
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [10, 10, 10, 10], ... % degrees/sec
    'apertureSize', 20, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast
    'onDuration', 36, ...  % in frames
    'offDuration',60, ... % in frames
    'numDirections',50, ... m
    'gazeContingent', false, ...
    'holdDuration', 30, ... % frames
    'task', 'faceforage', ... %'faceforage', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', true); % step through directions clockwise or counter



%% Hand Mapping of MT RF ... large field
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [10, 10, 10, 10], ... % degrees/sec
    'apertureSize', 20, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast
    'onDuration', 36, ...  % in frames
    'offDuration',60, ... % in frames
    'numDirections',12, ... m
    'gazeContingent', false, ...
    'holdDuration', 30, ... % frames
    'task', 'faceforage', ... %'faceforage', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', true); % step through directions clockwise or counter

%% Hand Mapping of MT RF ... large field, single direction you change by H and R key
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [15], ... % degrees/sec
    'apertureSize', 20, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast
    'onDuration', 120, ...  % in frames
    'offDuration', 80, ... % in frames
    'numDirections',1, ... % use H and R keystrokes to change direction
    'gazeContingent', false, ...
    'holdDuration', 30, ... % frames
    'task', 'faceforage', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', false); % step through directions clockwise or counter

%% Hand Mapping for MST with giant RF ... large field
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [15], ... % degrees/sec
    'apertureSize', 20, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast
    'onDuration', 12, ... %60, ...  % in frames
    'offDuration', 1, ... %60, ... % in frames
    'numDirections', 12, ... %12, ... 
    'gazeContingent', false, ...
    'holdDuration', 15, ... % frames
    'task', 'faceforage', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', false); % step through directions clockwise or counter

%% Hand Mapping of MT RF ... positioning of single aperture manually - SMALL
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [15], ... % degrees/sec
    'apertureSize', 5, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast 
    'onDuration', 30, ...  % in frames
    'offDuration', 30, ... % in frames
    'numDirections', 1, ... 
    'gazeContingent', false, ...
    'holdDuration', 15, ... % frames
    'task', 'fixflash', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', false);

%% Hand Mapping of MT RF ... positioning of single aperture manually - SMALL
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [15], ... % degrees/sec
    'apertureSize', 5, ...       % degrees
    'dotContrast', 1.0, ...      % ~Michelson contrast 
    'onDuration', 120, ...  % in frames
    'offDuration', 60, ... % in frames
    'numDirections', 1, ... 
    'gazeContingent', false, ...
    'holdDuration', 15, ... % frames
    'task', 'fixflash', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', false);

%% Fixed Mapping of MT ... move to RF, pause, then start record and resume
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [15], ... % degrees/sec
    'apertureSize', 3, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast 
    'onDuration', 24, ...  % in frames
    'offDuration', 36, ... % in frames
    'numDirections', 12, ... 
    'gazeContingent', false, ...
    'holdDuration', 15, ... % frames
    'task', 'fixflash', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', true);

