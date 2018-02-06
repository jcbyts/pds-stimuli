function p = runFixFlashSpatialMap(varargin)
% <strong>runFixFlashSpatialMap</strong> runs a reverse correlation spatial
% mapping protocol during fixation interleaved with trials of natural images.
% Arguments are passed in as pairs:
%   'subject':              name of subject (default: 'jnk')
%   'pauseBefore':          pause after loading PLDAPS (default: false)
%   'imageEveryNTrials':    show natural image trial every N trials
%   'imgDir':               full path to images (defaults to pictures of
%                           colony)
%   'minFixation':          minimum fixation time before reward (in seconds)
%   'fixPreStim':           fixation hold before showing spatial mapping
%                           stimulus (seconds; nan for continuously
%                           running)
%   'staircaseFixation':    should fixation duration increase and decrease
%                           depending on performance?
%   'fixationPoint':        'dot', 'bullseye', 'porthole'
ip = inputParser();
ip.addParameter('subject', 'jnk')
ip.addParameter('pauseBefore', false)
ip.addParameter('imageEveryNTrials', 4)
ip.addParameter('imgDir', getpref('pep', 'colonyPics'))
ip.addParameter('minFixation', .5)
ip.addParameter('fixPreStim', .01)
ip.addParameter('staircaseFixation', false)

ip.parse(varargin{:})

% setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% subject name
settingsStruct.session.subject = ip.Results.subject;
% save PDS file as this experimental protocol
settingsStruct.session.experimentName = mfilename;

%--------------------------------------------------------------------------
% Add Spatial Reverse Correlation module
sn = 'spatialSquares';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.spatialSquares';
settingsStruct.(sn).stateFunction.order = -1; % draw before behavior
settingsStruct.(sn).use = true;
settingsStruct.(sn).N = 4;
settingsStruct.(sn).contrast = 1;
settingsStruct.(sn).size = 1;
settingsStruct.(sn).position = [-5 5 5 -5];
settingsStruct.(sn).minFixation = ip.Results.fixPreStim;

%--------------------------------------------------------------------------
% Add foraging module
sn = 'forage';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.forage.forage';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
% foraging parameters -- Most of these parameters are overwritten below in
% the conditions!
settingsStruct.(sn).MotN                 = 3;            % number of moving targets
settingsStruct.(sn).minSpeed             = 1;            % minimum speed targets can move (deg/sec)
settingsStruct.(sn).maxSpeed             = 3;            % maximum speed (deg/sec)
settingsStruct.(sn).motionType           = 'randomwalk'; % motion follows this pattern (linear or randomwalk)
settingsStruct.(sn).type                 = 'face';       % face or grating
settingsStruct.(sn).appearGazeContingent = false;        % do the objects regenerate in a gaze-contingent coordinate frame
settingsStruct.(sn).appearRangePar       = 5;            % range of the generating distribution for the appearance of objects (deg)
settingsStruct.(sn).appearCenter         = [0 0];        % center of the regenerating distribution (deg, relative to center of screen)
settingsStruct.(sn).appearTau            = 10;            % do the objects fade on? (frames)
settingsStruct.(sn).maxContrast          = 1;            % contrast of the objects
settingsStruct.(sn).radius               = 1;            % radius of the objects (deg)
settingsStruct.(sn).onLifetime           = 1 * 120;      % time objects remain on (frames)
settingsStruct.(sn).offLifetime          = 2 * 120;      % time objects remain off (frames)   

% -------------------------------------------------------------------------
% porthole
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runImgScan';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
settingsStruct.(sn).staircaseOn = false;
settingsStruct.(sn).minFixDuration = 2;
settingsStruct.(sn).shrinkTimeConstant = 0;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;

% -------------------------------------------------------------------------
% fixflash normal -- which one should we use!?
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

settingsStruct.(sn).staircaseOn = true;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;