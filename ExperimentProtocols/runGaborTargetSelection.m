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
ip.addParameter('imageEveryNTrials', 4)
ip.addParameter('imgDir', getpref('pep', 'colonyPics'))
ip.addParameter('minFixation', .5)
ip.addParameter('fixPreStim', .01)
ip.addParameter('staircaseFixation', false)
ip.addParameter('fixationPoint', 'bullseye')
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

% set blend function appropriately
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;


% dot selection requires a fixation behavior
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.order = -1;
settingsStruct.(sn).use = true;

settingsStruct.(sn).staircaseOn    = false;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;
settingsStruct.(sn).showGUI = false;

sn = 'dotselection';
% settingsStruct.(sn).stateFunction.name = 'stimuli.modules.dotselection.runDefaultTrial';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.dotselection.runGaborsTrial';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

settingsStruct.(sn).fixationBehavior = 'fixflash'; % pointer to the fixation behavior
settingsStruct.(sn).staircaseOn = true;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;


if ip.Results.pauseBefore
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

settingsStruct = loadCalibration(settingsStruct);

% --- Open PLDAPS
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run