function p = runFaceForageHDmovie(varargin)
% <strong>runNaturalImageFreeView</strong> runs a full-field flash with marmoset
% faces doing a random walk on top of it interleaved with trials consisting
% of natural images.
% Arguments are passed in as pairs:
%   'subject':              name of subject (default: 'jnk')
%   'pauseBefore':          pause after loading PLDAPS (default: false)
%   'imgDir':               full path to images (defaults to pictures of
%                           colony)
%   'rewardAmount':         amount per reward (in ml)
%   'settingsStruct':       structure of rig preferences

ip = inputParser();
ip.addParameter('subject', 'jnk')
ip.addParameter('pauseBefore', false)
ip.addParameter('imgDir', getpref('pep', 'colonyPics'))
ip.addParameter('rewardAmount', 0.025)
ip.addParameter('settingsStruct', struct())
ip.parse(varargin{:})

settingsStruct = ip.Results.settingsStruct;

% Open GL Blend Function
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew      = GL_SRC_ALPHA;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction      ='runModularTrial';
settingsStruct.behavior.reward.defaultAmount   = ip.Results.rewardAmount;

settingsStruct.session.subject = ip.Results.subject;

% save PDS file as this experimental protocol
settingsStruct.session.experimentName = mfilename;

%--------------------------------------------------------------------------
% Add natural background module
sn='HDmovies';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.HDmovies';
settingsStruct.(sn).stateFunction.order = -100;
settingsStruct.(sn).use = true;


% %--------------------------------------------------------------------------
% % Add faceforage module
% sn='faceforage';
% settingsStruct.(sn).stateFunction.name = 'stimuli.forage.forage';
% settingsStruct.(sn).stateFunction.order = 2;
% settingsStruct.(sn).use = true;
% 
% % -------------------------------------------------------------------------
% % Add fixflash module
% sn = 'fixflash';
% settingsStruct.(sn).stateFunction.name = 'stimuli.fixflash.default';
% settingsStruct.(sn).stateFunction.order = 2;
% settingsStruct.(sn).use = true;

if ip.Results.pauseBefore
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

settingsStruct = loadCalibration(settingsStruct);


p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p = p.run;
