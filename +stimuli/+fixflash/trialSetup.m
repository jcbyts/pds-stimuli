function trialSetup(p, sn)

	if nargin < 2
		sn = 'stimulus';
	end

p.trial.pldaps.goodtrial = 1; % trial is listed as good

ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% --- Random seed
p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
setupRNG=p.trial.(sn).rngs.conditionerRNG;

% EYE CALIBRATION STUFF HERE

% % marmoview specific preferences override pldaps
% if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
%     p.trial.eyelink.useRawData=true;
%     p.trial.eyelink.calibration_matrix=[];
%     for i = 1:2 % loop over eye index
%         % get subject specific calibration matrix
%         cm=getCalibrationPref(p,1);
%         p.trial.eyelink.calibration_matrix(:,:,i) = cm';
%     end
%         
% end




% --- Fixation position
if p.trial.(sn).fixationJitter
    xpos = p.trial.(sn).fixationJitterSize * randn(setupRNG) + p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationJitterSize * randn(setupRNG) + p.trial.(sn).fixationY;
else
    xpos = p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationY;
end

% --- Set Fixation Point Properties
sz = p.trial.(sn).fixPointRadius * ppd;
p.trial.(sn).hFix(1).cSize      = sz;
p.trial.(sn).hFix(1).sSize      = 2*sz;
p.trial.(sn).hFix(1).cColour    = -ones(1,3);
p.trial.(sn).hFix(1).sColour    = ones(1,3);
p.trial.(sn).hFix(1).position   = [xpos ypos] * ppd + ctr;

p.trial.(sn).hFix(2).cSize      = sz;
p.trial.(sn).hFix(2).sSize      = 2*sz;
p.trial.(sn).hFix(2).cColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).sColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).position   = p.trial.(sn).hFix(1).position;



% fixation duration
p.trial.(sn).fixDuration = p.trial.(sn).minFixDuration;

% assert(p.trial.display.colorclamp | p.trial.display.normalizeColor, 'color range not [0-1]')

% --- Feedback for incorrect choices...
p.trial.(sn).hFbk.size      = 2 * p.trial.(sn).feedbackApertureRadius * ppd;
p.trial.(sn).hFbk.position  = p.trial.(sn).hFix(1).position;
p.trial.(sn).hFbk.colour    = p.trial.display.bgColor + p.trial.(sn).feedbackApertureContrast;
p.trial.(sn).hFbk.weight    = 4;

% --- Face for aditional reward
p.trial.(sn).hFace.texSize  = 2 * p.trial.(sn).faceRadius * ppd;
p.trial.(sn).hFace.position = p.trial.(sn).hFix(1).position;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Reward
p.trial.(sn).hReward.defaultAmount = p.trial.behavior.reward.defaultAmount;
p.trial.(sn).hReward.iTrial        = p.trial.pldaps.iTrial;

% --- Setup dot motion trial
% the @trial object (initially in state 0)
% hFix,hDots,hChoice,hCue,hFace,hReward,
p.trial.(sn).hTrial = stimuli.fixflash.fixFlashTrial( ...
  p.trial.(sn).hFix,p.trial.(sn).hFbk,p.trial.(sn).hFace, ...
  p.trial.(sn).hReward, ...
  'fixWinRadius',p.trial.(sn).fixWinRadius, ...
  'fixGracePeriod',p.trial.(sn).fixGracePeriod, ...
  'fixDuration', p.trial.(sn).minFixDuration, ...
  'fixFlashCnt',p.trial.(sn).fixFlashCnt, ...
  'holdDuration',p.trial.(sn).holdDuration, ...
  'trialTimeout',p.trial.(sn).trialTimeout, ...
  'iti',p.trial.(sn).iti, ...
  'maxRewardCnt',p.trial.(sn).maxRewardCnt, ...
  'rewardLevels', p.trial.(sn).rewardLevels, ...
  'viewpoint',false);
end

% function c=getCalibrationPref(p, eyeIdx)
% % Get calibration matrix from rig preferences
% % cm = getCalibrationPref(p, eyeIdx)
% % Input:
% %   p     [pldaps] - pldaps object
% %   eyeIdx [1 x 1] - index for eye (1 or 2; optional)
% % Output:
% %   cm     [3 x 2] - calibration matrix
% 
% % get subject name
% subj=p.trial.session.subject;
% 
% % if no index is passed in, query the eyelink to get the proper index
% if nargin < 2
%     useEyelink = p.trial.eyelink.use & p.trial.eyelink.useAsEyepos;
%     if useEyelink
%         if isfield(p.trial.eyelink, 'eyeIdx')
%             eyeIdx = p.trial.eyelink.eyeIdx;
%         else
%             eyeIdx = 1;
%         end
%     else
%         eyeIdx = 1;
%     end
% end
% end