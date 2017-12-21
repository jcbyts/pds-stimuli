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
    choiceX@double = NaN;
    choiceY@double = NaN;
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
    hFbk@handle;
    hFace@handle;
    
    % trial objects
%     hEye@handle; % FIXME: eye tracker?
    viewpoint@logical = false;
    hPldaps%     hReward@handle;
    
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
    bonus@double  = []; % look-up table for bonus schedule
  end
  
  methods (Access = public)
    function o = dotMotionTrial(hFix,hDots,hChoice,hCue,hFbk,hFace,hPldaps,varargin),
      o.hFix    = hFix;
      o.hDots   = hDots;
      o.hChoice = hChoice;
      o.hCue    = hCue;
      o.hFbk    = hFbk;
      o.hFace   = hFace;
      
      o.hPldaps = hPldaps;
      
      % initialise the @state object pool...
      o.addState(stimuli.dotmotion.state0_FixWait(o));
      o.addState(stimuli.dotmotion.state1_FixGracePeriod(o));
      o.addState(stimuli.dotmotion.state2_FixPreStim(o));
      o.addState(stimuli.dotmotion.state3_ShowDots(o));
      o.addState(stimuli.dotmotion.state4_WaitForGo(o));
      o.addState(stimuli.dotmotion.state5_Choice(o));
      o.addState(stimuli.dotmotion.state6_HoldChoice(o));
      o.addState(stimuli.dotmotion.state7_BreakFixTimeout(o));
      o.addState(stimuli.dotmotion.state8_InterTrialInterval(o));
      
      % set initial state
      o.setState(0);      
      
      if nargin < 5
        return
      end
      
      % initialise input parser
      args = varargin;
      p = inputParser;
%       p.KeepUnmatched = true;
      p.StructExpand = true;
      p.addParameter('fixWinRadius',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('fixGracePeriod',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('fixDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('fixFlashCnt',NaN,@(x) isscalar(x) && isreal(x)); % frames
      p.addParameter('stimDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('holdDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('cueDelay',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('choiceTargetDelay',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('choiceWinMinRadius',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('choiceWinMaxRadius',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('choiceGracePeriod',NaN,@(x) isscalar(x) && isreal(x)); 
      p.addParameter('choiceDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('rewardWindow',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('choiceTimeout',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('trialTimeout',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('iti',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      
      p.addParameter('maxRewardCnt',NaN,@(x) isscalar(x) && isreal(x));
      
      p.addParameter('bonusDirection',NaN,@(x) isscalar(x) && isreal(x)); % deg
      p.addParameter('bonusWindow',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('bonusRewardCnt',o.bonusRewardCnt,@(x) isscalar(x) && isreal(x));
      
      p.addParameter('viewpoint',false,@islogical);
      
      try
        p.parse(args{:});
      catch
        warning('Failed to parse name-value arguments.');
        return;
      end
      
      args = p.Results;
    
      o.fixWinRadius        = args.fixWinRadius;
      o.fixGracePeriod      = args.fixGracePeriod;
      o.fixDuration         = args.fixDuration;
      o.fixFlashCnt         = args.fixFlashCnt;
      o.stimDuration        = args.stimDuration;
      o.holdDuration        = args.holdDuration;
      o.cueDelay            = args.cueDelay;
      o.choiceTargetDelay   = args.choiceTargetDelay;
      o.choiceWinMinRadius  = args.choiceWinMinRadius;
      o.choiceWinMaxRadius  = args.choiceWinMaxRadius;
      o.choiceGracePeriod   = args.choiceGracePeriod;
      o.choiceDuration      = args.choiceDuration;
      o.rewardWindow        = args.rewardWindow;
      o.choiceTimeout       = args.choiceTimeout;
      o.trialTimeout        = args.trialTimeout;
      o.iti                 = args.iti;
            
      o.maxRewardCnt        = args.maxRewardCnt;
      
      o.bonusDirection      = args.bonusDirection;
      o.bonusWindow         = args.bonusWindow;
      o.bonusRewardCnt      = args.bonusRewardCnt;
      
      o.viewpoint           = args.viewpoint;
      
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
