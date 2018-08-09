function p = runFaceForageHartley(varargin)
% <strong>runFaceForageHartley</strong> runs full field hartley basis in
% the background while the subject forages for targets interleaved with
% trials of natural images.
% Arguments are passed in as pairs:
%   'subject':              name of subject (default: 'jnk')
%   'pauseBefore':          pause after loading PLDAPS (default: false)
%   'imageEveryNTrials':    show natural image trial every N trials
%   'imgDir':               full path to images (defaults to pictures of
%                           colony)
%   'autoCorr':             'fixed' or 'exponential'
%                           this specifies how the OnDuration and
%                           OffDuration parameters are interpreted (as taus
%                           of an exponential distribution, or as fixed
%                           values of duration)

ip = inputParser();
ip.addParameter('subject', 'jnk')
ip.addParameter('pauseBefore', false)
ip.addParameter('imageEveryNTrials', 4)
ip.addParameter('imgDir', getpref('pep', 'colonyPics'))
ip.addParameter('autoCorr', 'pBlank')
ip.addParameter('settingsStruct', struct())
ip.parse(varargin{:})

settingsStruct = ip.Results.settingsStruct;

settingsStruct.display.sourceFactorNew = GL_ONE;
settingsStruct.display.destinationFactorNew = GL_ONE;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% subject name
settingsStruct.session.subject = ip.Results.subject;
% save PDS file as this experimental protocol
settingsStruct.session.experimentName = mfilename;

%--------------------------------------------------------------------------
% Add Hartley module
sn = 'hartley';
switch ip.Results.autoCorr
    case 'exponential'
        settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.hartley.defaultHartleyTrial';
        settingsStruct.(sn).OffDuration = 2;
    case 'fixed'
        settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.hartley.hartleyTrialFixedDuration';
        settingsStruct.(sn).OffDuration = 2;
    case 'pBlank'
        settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.hartley.hartleyTrialWeightedProbability';
        settingsStruct.(sn).pBlank = .2;
end
settingsStruct.(sn).stateFunction.order = -1; % draw before behavior
settingsStruct.(sn).use = true;
settingsStruct.(sn).OnDuration  = 6;
settingsStruct.(sn).contrast    = .1;  % Michelson contrast of the gratings (DEPENDS ON BLEND FUNCTION)
settingsStruct.(sn).tfs         = 0;   % temporal frequencies showns
settingsStruct.(sn).nOctaves    = 5;   % number of octaves to show above base frequency
settingsStruct.(sn).Freq0       = .2;  % Base frequence (cycles/deg)

% frozen seed
settingsStruct.(sn).rngs.trialSeeds = repmat(666, 3e3, 1);

%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.natImgBackground';
settingsStruct.(sn).stateFunction.order = -1;
settingsStruct.(sn).use = true;
settingsStruct.(sn).imageContrast = .4;
settingsStruct.(sn).numToShow     = 1; % number of images to show per trial
settingsStruct.(sn).imgDir = ip.Results.imgDir;
% settingsStruct.(sn).imgDir = '/media/marmorig/Data/RangeDatabase1080p/';
% settingsStruct.(sn).fileList=dir(fullfile(p.trial.(sn).imgDir, 'lImage*V.png'));

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
settingsStruct.(sn).holdDuration         = 1.5;

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

% --- Condition 1: Face Forage with CSD flash
sn  = 'forage';
iCond = 1;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN                 = 2;  % number of face objects
c{iCond}.(sn).appearTau            = 5;
c{iCond}.natImgBackground.use = false;
c{iCond}.natImgBackground.on = false;
c{iCond}.hartley.use = true;

% --- Condition 2: Face Forage on Natural background
iCond = 2;
c{iCond} = struct(sn, struct());
c{iCond}.Nr = iCond;
c{iCond}.(sn).MotN                  = 3;  % number of face objects
c{iCond}.(sn).minSpeed              = 0;  % faces don't move in this protocol
c{iCond}.(sn).maxSpeed              = 0;  % faces don't move in this protocol
c{iCond}.(sn).appearRangePar        = 3;
c{iCond}.(sn).appearCenter          = [0 -2];
c{iCond}.(sn).appearTau             = 60; % faces take half a second to fade in
c{iCond}.(sn).maxContrast           = .5;
c{iCond}.(sn).onLifetime            = ceil(2 * 120);
c{iCond}.(sn).offLifetime           = ceil(3 * 120);
% --- modules
c{iCond}.natImgBackground.use   = true;
c{iCond}.natImgBackground.on    = false;
c{iCond}.hartley.use            = false;


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

p.defaultParameters.pldaps.finish = 45; % complete ~15 minutes of data in 45 trials

condIdx = repmat(condNums, 1, ceil(p.defaultParameters.pldaps.finish/numel(condNums)));

for iTrial = (numel(p.data)+1):p.defaultParameters.pldaps.finish
    p.conditions{iTrial} = c{condIdx(iTrial)};
end

% --- Run
p = p.run;