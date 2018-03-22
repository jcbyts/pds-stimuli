function p = runGaborTargetSelection(varargin)
% <strong>runGaborTargetSelection</strong> runs a reverse correlation spatial
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
ip.addParameter('imageEveryNTrials', 25)
ip.addParameter('imgDir', getpref('pep', 'colonyPics'))
ip.addParameter('minFixation', .5)
ip.addParameter('fixPreStim', .01)
ip.addParameter('staircaseFixation', false)
ip.addParameter('fixationPoint', 'bullseye')
ip.addParameter('SingleTarget', 0)
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
% Target selection Module

% % set blend function appropriately
% settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
% settingsStruct.display.sourceFactorNew      = GL_SRC_ALPHA;


% dot selection requires a fixation behavior
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.order = -1;
settingsStruct.(sn).use = true;

settingsStruct.(sn).staircaseOn        = false;
settingsStruct.(sn).minFixDuration     = .2;
settingsStruct.(sn).fixationJitter     = false;
settingsStruct.(sn).fixationJitterSize = 0;
settingsStruct.(sn).rewardLevels       = inf; % no amount of fixation could ever yield reward
settingsStruct.(sn).showGUI            = false;
settingsStruct.(sn).fixWinRadius       = 1.2; 
settingsStruct.(sn).rewardFaceDuration =   0;
settingsStruct.(sn).rewardForFixation  = 0.5; 
%settingsStruct.(sn).rewardForFixation  = -0.2;  % if positive, it is a probability to reward for 
                                                % holding fixation, if
                                                % negative then it is time
                                                % in seconds that if you
                                                % hold after fixation
                                                % offset, you get a drop
settingsStruct.(sn).FixEngagePenalty  = false;
settingsStruct.(sn).waitForSaccade    = true;

sn = 'dotselection';
% settingsStruct.(sn).stateFunction.name = 'stimuli.modules.dotselection.runDefaultTrial';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.dotselection.runGaborsTrial';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

settingsStruct.(sn).fixationBehavior = 'fixflash'; % pointer to the fixation behavior
settingsStruct.(sn).RfCenterXy   =            [3, -3];
settingsStruct.(sn).contrast=                 .25;
settingsStruct.(sn).tf=                       10;
settingsStruct.(sn).sf=                       4;
settingsStruct.(sn).numDirs=                  8;
settingsStruct.(sn).CenterAngle=              [0 -90];
settingsStruct.(sn).rewardUpdateFun=          @stimuli.modules.dotselection.rewardUpdateSwitchRule;
 settingsStruct.(sn).rewardUpdateArgs=        {0.25};  % swap duration (only if single target)
settingsStruct.(sn).rewardForFixation=        false;
settingsStruct.(sn).rewardFaceDuration=       0.5;
settingsStruct.(sn).yokeDirections=           false;      % yoke the direction of dots for dots1 and dots2
settingsStruct.(sn).rewardDot1Rate=           1.0; %1;
settingsStruct.(sn).rewardDot2Rate=           0.0; %0.85;
settingsStruct.(sn).maxRewardCnt=             3;          % max drops of juice
settingsStruct.(sn).faceIndex=                1;
settingsStruct.(sn).minFixPreStim=            0.1;
settingsStruct.(sn).maxFixPreStim=            0.2;
settingsStruct.(sn).minFixPostStim=           0.1;
settingsStruct.(sn).maxFixPostStim=           0.2;        % seconds (wrt dot motion onset)
settingsStruct.(sn).fixHoldTau=               0.2;        % seconds(time constant of exponential)
settingsStruct.(sn).choiceGracePeriod=        0.2;  %1.4; % grace period for decision time (seconds)
settingsStruct.(sn).choiceHoldDuration=       0.1;      % minimum choice hold duration (seconds)
settingsStruct.(sn).iti=                      1.0;
settingsStruct.(sn).rewardcount=              zeros(1,2); % two targets, only two states
settingsStruct.(sn).rewardtravel=             4;          % must choose this many times before move
settingsStruct.(sn).rewardtransit=            1.0;        % prob to transition reward state

if (ip.Results.SingleTarget == 1)
  settingsStruct.(sn).stimVisible=              [1 0 1 0 0]; % single target shown    
else
  settingsStruct.(sn).stimVisible=              [1 0.05 0 0 0]; % both targets be shown
  settingsStruct.(sn).trialsToSwap =            8;   % this many trials correct, then swap
end

if ip.Results.pauseBefore
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

settingsStruct = loadCalibration(settingsStruct);

% --- Open PLDAPS
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

%****** one dummy condition **********************************
%********* setup conditions before running ********************
c{1} = struct(sn, struct());
p.defaultParameters.pldaps.finish = 200;  % 200 trials, all same dummy condition
for iTrial = (numel(p.data)+1):p.defaultParameters.pldaps.finish
    p.conditions{iTrial} = c{1};
end

p = p.run;