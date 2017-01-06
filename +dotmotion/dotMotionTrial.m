classdef dotMotionTrial < stimuli.trial
  % @trial class for the dot motion task
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    trialNum@double = 0;
    
    done@logical = false; % true when trial is complete
        
    x; % gaze position (deg.)
    y;
    
%     pixPerDeg@double;
%     scrWdth@double; % screen width in pixels
%     scrHght@double; % screen height in pixels
    choice@double = NaN;    

    % 'error' describes the outcome of a trial:
    %
    %   0 = complete trial, correct response
    %   1 = failure to fixate the target (within trialTimeout)
    %   2 = failure to hold fixation until stimulus onset (fixDuration)
    %   3 = failure to maintain fixation during stimulus (holdDuration)
    %   4 = failure to initiate choice (within choiceTimeout)
    %   5 = failure to hold the choice target
    %   6 = complete trial, incorrect response
    error@double = 0;
  
    % stimulus objects
    hFix@handle;
    hDots@handle;
    hChoice@handle;
    hCue@handle;
    hFace@handle;
    
    % trial objects
%     hEye@handle; % FIXME: eye tracker?
    viewpoint@logical = false;
    hReward@handle;
    
    % flags...?
    showFix = true;
    showCue = false;
    showChoice = true; % FIXME: true?
    
    % task/trial parameters
    fixWinRadius@double;        % deg.
    fixGracePeriod@double;      % seconds
    fixDuration@double;         % seconds
    fixFlashCnt@double;         % frames
    stimDuration@double;        % seconds
    holdDuration@double;        % seconds
    cueDelay@double;            % seconds
    choiceTargetDelay@double;   % seconds
    choiceWinMinRadius@double;  % deg.
    choiceWinMaxRadius@double;  % deg.
    choiceGracePeriod@double;   % seconds
    choiceDuration@double;      % seconds
    rewardWindow@double;        % deg.
    choiceTimeout@double;       % seconds
    trialTimeout@double;        % seconds
    iti@double;                 % inter-trial interval (seconds)
    maxRewardCnt@double;
    
    rewardCnt@double = 0;
    
    bonusDirection@double; % deg.
    bonusWindow@double; % deg.
    bonusRewardCnt@double = 0;
  end

  % FIXME: nast hack here... make 'reward' and 'bonus' public so we
  %        can stash them in A (in dotMotionRun()) to be plotted in
  %        dotMotionEnd()
  
%   properties (Access = ?stimuli.state)
  properties (Access = public)
    reward@double = []; % look-up table for reward schedule
    bonus@double = []; % look-up table for bonus schedule
  end
  
  methods (Access = public)
    function o = dotMotionTrial(hFix,hDots,hChoice,hCue,hFace,hReward,varargin),
      o.hFix = hFix;
      o.hDots = hDots;
      o.hChoice = hChoice;
      o.hCue = hCue;
      o.hFace = hFace;
      
      o.hReward = hReward;
      
      % initialise the @state object pool...
      o.addState(stimuli.dotmotion.dotMotionState0(o));
      o.addState(stimuli.dotmotion.dotMotionState1(o));
      o.addState(stimuli.dotmotion.dotMotionState2(o));
      o.addState(stimuli.dotmotion.dotMotionState3(o));
      o.addState(stimuli.dotmotion.dotMotionState4(o));
      o.addState(stimuli.dotmotion.dotMotionState5(o));
      o.addState(stimuli.dotmotion.dotMotionState6(o));
      o.addState(stimuli.dotmotion.dotMotionState7(o));
      o.addState(stimuli.dotmotion.dotMotionState8(o));
      
      % set initial state
      o.setState(0);      
      
      if nargin < 5,
        return
      end
      
      % initialise input parser
      args = varargin;
      p = inputParser;
%       p.KeepUnmatched = true;
      p.StructExpand = true;
      p.addParamValue('fixWinRadius',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParamValue('fixGracePeriod',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('fixDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('fixFlashCnt',NaN,@(x) isscalar(x) && isreal(x)); % frames
      p.addParamValue('stimDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('holdDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('cueDelay',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('choiceTargetDelay',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('choiceWinMinRadius',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParamValue('choiceWinMaxRadius',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParamValue('choiceGracePeriod',NaN,@(x) isscalar(x) && isreal(x)); 
      p.addParamValue('choiceDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('rewardWindow',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParamValue('choiceTimeout',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('trialTimeout',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParamValue('iti',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      
      p.addParamValue('maxRewardCnt',NaN,@(x) isscalar(x) && isreal(x));
      
      p.addParamValue('bonusDirection',NaN,@(x) isscalar(x) && isreal(x)); % deg
      p.addParamValue('bonusWindow',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParamValue('bonusRewardCnt',o.bonusRewardCnt,@(x) isscalar(x) && isreal(x));
      
      p.addParamValue('viewpoint',false,@islogical);
      
      try
        p.parse(args{:});
      catch,
        warning('Failed to parse name-value arguments.');
        return;
      end
      
      args = p.Results;
    
      o.fixWinRadius = args.fixWinRadius;
      o.fixGracePeriod = args.fixGracePeriod;
      o.fixDuration = args.fixDuration;
      o.fixFlashCnt = args.fixFlashCnt;
      o.stimDuration = args.stimDuration;
      o.holdDuration = args.holdDuration;
      o.cueDelay = args.cueDelay;
      o.choiceTargetDelay = args.choiceTargetDelay;
      o.choiceWinMinRadius = args.choiceWinMinRadius;
      o.choiceWinMaxRadius = args.choiceWinMaxRadius;
      o.choiceGracePeriod = args.choiceGracePeriod;
      o.choiceDuration = args.choiceDuration;
      o.rewardWindow = args.rewardWindow;
      o.choiceTimeout = args.choiceTimeout;
      o.trialTimeout = args.trialTimeout;
      o.iti = args.iti;
            
      o.maxRewardCnt = args.maxRewardCnt;
      
      o.bonusDirection = args.bonusDirection;
      o.bonusWindow = args.bonusWindow;
      o.bonusRewardCnt = args.bonusRewardCnt;
      
      o.viewpoint = args.viewpoint;
      
      %
      % calculate reward schedule... as a function of angular error
      %
      
      % calculate k to give >0.5*maxRewardCnt within rewardWindow
      % around the true direction
      k = log(0.5)./(cos((pi/180)*(o.rewardWindow/2))-1);

      o.reward = o.vonMises([o.maxRewardCnt, 0.0, k], 0:360); % 1 deg. resolution...?

      % bonus reward... to correct for spatial choice bias?
      th = -180:180; % 1 deg. resolution
      bonus = zeros(size(th));
      bonus(find(abs(th) < (o.bonusWindow/2))) = o.bonusRewardCnt;
      o.bonus = circshift(bonus(:),o.bonusDirection-180)';      
    end
    
%     function d = report(o),
%       d = struct('rndState',o.rndState);
%     end
  end % methods
  
  methods (Static)
    function y = vonMises(p,x),
      % VONMISES The Von Mises function.
      %  Y = VONMISES(P,X) calculates the von Mises function defined by the
      %  parameter vector P, at locations X (expressed in deg.).
      %
      %  The von Mises function is defined as:
      %
      %       y = A * exp(k * (cos((pi/180)*(x-u))-1))
      %
      %     where A is the maximum amplitude
      %           u is the mean (i.e., the position of the peak)
      %           k is a measure of the concentration of the distribution
      %                around the peak
      %
      %     the parameter vector p is defined as
      %
      %       p = [A, u, k]

      assert(isvector(x),'argument x is not a vector!');

      y = zeros([size(p,1),length(x)]);
      for ii = 1:size(p,1),
        y(ii,:) = p(ii,1) .* exp(p(ii,3)*(cos((pi/180)*(x - p(ii,2)))-1));
      end
    end
  end % static methods
  
end % classdef
