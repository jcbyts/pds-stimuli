%% Sample experiments

subject = 'Ellie'; % Ellie (Capitalized)
pauseBeforeExperiment = 0;

%% Test subject case
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

%% MT mapping: Dot motion
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

subject = 'test';
settingsStruct = struct();
% settingsStruct.display.destinationFactorNew = GL_ONE;

pauseBeforeExperiment = 0;
settingsStruct.display.colorclamp = 1;
settingsStruct.display.normalizeColor = 1;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount= 0.05; %.015;

settingsStruct.session.subject=subject;

settingsStruct.stimulus.fixWinRadius = 1.5;
settingsStruct.stimulus.fixPointRadius = .3;
settingsStruct.stimulus.holdDuration = 15; % frames (counter, not continuous)
settingsStruct.stimulus.RfCenterXy = [4 -4];
settingsStruct.stimulus.DotCenterAngle(1) = 0;
settingsStruct.stimulus.DotCenterAngle(2) = -90;

% The reward function I coded up will switch which target has the higher
% reward reate randomly with a switch rate of .1, meaning each trial a
% random number is drawn and if it is less than .1, the reward scheme will
% switch
settingsStruct.stimulus.rewardUpdateFun = @stimuli.dotselection.rewardUpdateSwitchRule;
settingsStruct.stimulus.rewardUpdateArgs = {.1}; % low rate, high rate

settingsStruct.pldaps.draw.cursor.use = true;

if pauseBeforeExperiment
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

try
    cm = getpref('marmoview_calibration', subject);
    cm2 = cm(:,:,1)';
    cm2(:,:,2) = cm(:,:,2)';
    
    settingsStruct.eyelink.calibration_matrix = cm2;
    settingsStruct.eyelink.useRawData = true;
catch me
    throw(me)
end

if strcmp(subject, 'test')
    settingsStruct.eyelink.use = false;
    settingsStruct.mouse.useAsEyepos = true;
end

p = pldaps(@stimuli.dotselection.OneInRF, subject, settingsStruct);

p.run

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

%% Decoding stimulus: limited range
runDotHandMapping(subject, pauseBeforeExperiment, ...
    'priorMu', 180, ...
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
%% Decoding stimulus: full range
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

