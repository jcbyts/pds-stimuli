subject = 'Harold';% 'Harold'
pauseBeforeExperiment = false;
collectEyelinkQueue = false; % can lead to dropped frames if true
%% Natural Image Free View: warm up
close all

settingsStruct = struct();
settingsStruct.pldaps.maxTrialLength = 60;
settingsStruct.newEraSyringePump.vol = .05;
settingsStruct.eyelink.collectQueue = collectEyelinkQueue;

p = runNaturalImageFreeView('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imgDir', getpref('pep', 'colonyPics'), ...
    'settingsStruct', settingsStruct);

pds.plotTiming(p, true);

%% Face Forage with CSD
close all

settingsStruct = struct();
settingsStruct.pldaps.maxTrialLength = 20;
settingsStruct.pldaps.finish = 60*5/settingsStruct.pldaps.maxTrialLength;
settingsStruct.newEraSyringePump.vol = .025;
settingsStruct.eyelink.collectQueue = collectEyelinkQueue;

p = runFaceForageCSD('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'onDuration', 50, ...
    'offDuration', 150, ...
	'imgDir', getpref('pep', 'colonyPics'), ...
    'imageEveryNTrials', 10, ...
    'settingsStruct', settingsStruct);

pds.plotTiming(p, true);

%% Face Forage with spatial mapping (large)
close all

settingsStruct = struct();
settingsStruct.pldaps.maxTrialLength = 20;
settingsStruct.pldaps.finish = 60*10/settingsStruct.pldaps.maxTrialLength + 5;
settingsStruct.newEraSyringePump.vol = .035;
settingsStruct.eyelink.collectQueue = collectEyelinkQueue;

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 10; % number of squares on each frame
spatialSquaresOpts.lifetime = 8; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrpees) 
% spatialSquaresOpts.size = .25;
spatialSquaresOpts.position = [-20 20 20 -20]; % stimulus rect (in degrees) 
spatialSquaresOpts.size = 1; % made it smaller. let's see if this works -- Jake
spatialSquaresOpts.contrast = 1;


p = runFaceForageSpatialMapping('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 10, ...
    'settingsStruct', settingsStruct);

pds.plotTiming(p, true)

%% Face Forage with spatial mapping (tiny)
close all

settingsStruct = struct();
settingsStruct.pldaps.maxTrialLength = 20;
settingsStruct.pldaps.finish = 60*10/settingsStruct.pldaps.maxTrialLength + 5;
settingsStruct.newEraSyringePump.vol = .035;
settingsStruct.eyelink.collectQueue = collectEyelinkQueue;

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 400; % number of squares on each frame
spatialSquaresOpts.lifetime = 8; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrpees) 
% spatialSquaresOpts.size = .25;
spatialSquaresOpts.position = [-20 20 20 -20]; % stimulus rect (in degrees) 
spatialSquaresOpts.size = .1; % made it smaller. let's see if this works -- Jake
spatialSquaresOpts.contrast = 1;


p = runFaceForageSpatialMapping('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 10, ...
    'settingsStruct', settingsStruct);

pds.plotTiming(p, true)

%% Face Forage with Hartley 1: pBlank
close all

settingsStruct = struct();
settingsStruct.pldaps.maxTrialLength = 20;
settingsStruct.pldaps.finish = 60*10/settingsStruct.pldaps.maxTrialLength;
settingsStruct.newEraSyringePump.vol = .035;
settingsStruct.eyelink.collectQueue = collectEyelinkQueue;

p = runFaceForageHartley('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imageEveryNTrials', 5, ...
    'autoCorr', 'pBlank', ...
    'pBlank', 0.5, ...
    'Contrast', 0.10, ...m
    'settingsStruct', settingsStruct);

pds.plotTiming(p, true);

%% Face Forage with Hartley 1: exponentialDecay
close all

settingsStruct = struct();
settingsStruct.pldaps.maxTrialLength = 15;
settingsStruct.pldaps.finish = 60*10/settingsStruct.pldaps.maxTrialLength;
settingsStruct.newEraSyringePump.vol = .035;
settingsStruct.eyelink.collectQueue = collectEyelinkQueue;

p = runFaceForageHartley('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imageEveryNTrials', 15, ...
    'autoCorr', 'exponentialDecay', ...
    'Contrast', 0.10, ...
    'settingsStruct', settingsStruct);

pds.plotTiming(p, true);




%% HD movies
close all

% make everything bigger (viewdist scales the pixels per degree
% calculation)
settingsStruct = struct();
settingsStruct.session.subject = subject;
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;
settingsStruct.display.useOverlay = 1;
settingsStruct.pldaps.pause.preExperiment = false;
settingsStruct.pldaps.maxTrialLength = 30;
settingsStruct.eyelink.collectQueue = collectEyelinkQueue;

sn = 'HDmovies';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.HDmovies';
settingsStruct.(sn).stateFunction.order = 1;    % when to run this module with respect to other modules
settingsStruct.(sn).use                 = true; % use this module
settingsStruct.(sn).moviedatabase = 'videos';
% calling pldaps with @stimuli.pldapsDefaultTrial will make sure that
% pldaps takes all the measurements that are required for our modules
% (e.g., eye position)

settingsStruct = loadCalibration(settingsStruct);

p = pldaps(settingsStruct);

p = p.run;

pds.plotTiming(p, true);


%% Fixation with spatial mapping
close all

spatialSquaresOpts = struct();
spatialSquaresOpts.N        = 2; % number of squares on each frame
spatialSquaresOpts.lifetime = 8; % lifetime of squares frames
% spatialSquaresOpts.position = [1 -1 5 -5]; % stimulus rect (in degrpees) 
% spatialSquaresOpts.size = .25;
%spatialSquaresOpts.position = [-5 5 5 -5]; % stimulus rect (in degrees) 
spatialSquaresOpts.position = [4 2 12 -6];
spatialSquaresOpts.size = 0.5;
spatialSquaresOpts.contrast = 1.0;

close all

p = runFixFlashSpatialMap('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,...
    'spatialSquares', spatialSquaresOpts, ...
    'imageEveryNTrials', 50, ...
    'fixationPoint', 'bullseye', ...
    'staircaseFixation', true, ...
    'settingsStruct', settingsStruct);

pds.plotTiming(p, true);


%% Presaccadic selection with gabors

close all

SingleTarget = 0;
p = runGaborTargetSelection('subject', subject,...
    'pauseBefore', pauseBeforeExperiment,'SingleTarget', SingleTarget);

pds.plotTiming(p, true);

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


