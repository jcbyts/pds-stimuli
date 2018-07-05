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
ip.addParameter('fixationPoint', 'bullseye')
ip.addParameter('spatialSquares', [])
ip.addParameter('settingsStruct', struct())
ip.parse(varargin{:})

settingsStruct = ip.Results.settingsStruct;

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
defopts = struct('N', 4, ...
    'contrast',     1, ...
    'size',         1, ...
    'lifetime',     2, ...
    'position',     [0 0 5 -5], ...
    'minFixation',  .01, ...
    'gridded',      true);

settingsStruct.(sn) = dvmergefield(settingsStruct.(sn), defopts, 1);
if ~isempty(ip.Results.(sn)) && isstruct(ip.Results.(sn))
    settingsStruct.(sn) = dvmergefield(ip.Results.(sn), settingsStruct.(sn), 1);
end

%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.natImgBackground';
settingsStruct.(sn).stateFunction.order = -1;
settingsStruct.(sn).use = true;
settingsStruct.(sn).imageContrast = .5;
settingsStruct.(sn).numToShow     = 1; % number of images to show per trial
settingsStruct.(sn).imgDir = ip.Results.imgDir;


%--------------------------------------------------------------------------
% Add foraging module
sn = 'forage';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.forage.forage';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
% foraging parameters -- Most of these parameters are overwritten below in
% the conditions!
settingsStruct.(sn).MotN                 = 3;            % number of moving targets
settingsStruct.(sn).minSpeed             = 0;            % minimum speed targets can move (deg/sec)
settingsStruct.(sn).maxSpeed             = 0;            % maximum speed (deg/sec)
settingsStruct.(sn).motionType           = 'randomwalk'; % motion follows this pattern (linear or randomwalk)
settingsStruct.(sn).type                 = 'face';       % face or grating
settingsStruct.(sn).appearGazeContingent = false;        % do the objects regenerate in a gaze-contingent coordinate frame
settingsStruct.(sn).appearRangePar       = 3;            % range of the generating distribution for the appearance of objects (deg)
settingsStruct.(sn).appearCenter         = [0 -2];        % center of the regenerating distribution (deg, relative to center of screen)
settingsStruct.(sn).appearTau            = 60;            % do the objects fade on? (frames)
settingsStruct.(sn).maxContrast          = .5;            % contrast of the objects
settingsStruct.(sn).radius               = 1;            % radius of the objects (deg)
settingsStruct.(sn).onLifetime           = 2 * 120;      % time objects remain on (frames)
settingsStruct.(sn).offLifetime          = 3 * 120;      % time objects remain off (frames)

% -------------------------------------------------------------------------
% fixation
sn = 'fixflash';
switch ip.Results.fixationPoint
    
    case 'porthole'
        settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runImgScan';        
        
    case 'bullseye'
        settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
end

settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

settingsStruct.(sn).staircaseOn = true;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;
settingsStruct.(sn).maxFixDuration = 1.5;
settingsStruct.(sn).staircaseStep = .075;
settingsStruct.(sn).staircaseMax = 1.5;
settingsStruct.(sn).fixWinRadius = 1.5;


if ip.Results.pauseBefore
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

settingsStruct = loadCalibration(settingsStruct);

% --- Open PLDAPS
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

% --- Build conditions
% this is how we interleave trials with different combinations of modules.
% We build a "condition" and then assign it to different trial numbers

% --- Condition 1: Fix Flash with spatial mapping

iCond = 1;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.forage.use             = false;
c{iCond}.fixflash.use           = true;
c{iCond}.natImgBackground.use   = false;
c{iCond}.spatialSquares.use     = true;

% --- Condition 2: Face Forage on Natural background
iCond = 2;
sn  = 'forage';
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.forage.use             = true;
c{iCond}.fixflash.use           = false;
c{iCond}.natImgBackground.use   = true;
c{iCond}.spatialSquares.use     = false;


% --- setup number of conditions        
condN = ones(1,iCond);
if isnan(ip.Results.imageEveryNTrials)
    condN(2) = 0;
else
    condN(1) = ip.Results.imageEveryNTrials-1;
end

condNums = [];
for iCond = 1:numel(c)
    condNums = [condNums ones(1,condN(iCond))*iCond]; %#ok<AGROW>
end

p.defaultParameters.pldaps.finish = 200;

condIdx = repmat(condNums, 1, ceil(p.defaultParameters.pldaps.finish/numel(condNums)));

for iTrial = (numel(p.data)+1):p.defaultParameters.pldaps.finish
    p.conditions{iTrial} = c{condIdx(iTrial)};
end

% --- Run
p = p.run;


