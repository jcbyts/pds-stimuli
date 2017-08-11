classdef dotMotionTrial < stimuli.trial
  % @trial class for the dot motion task
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    trialNum@double = 0;
    
    done@logical = false; % true when trial is complete
        
    x; % gaze position
    y;
    
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
    error@double = 0
  
    % stimulus objects
    hFix@handle
    hDots@handle
    hFace@handle
    hReward@handle
    
    % trial objects
    viewpoint@logical = false;
    
    % flags...?
    showFix  = true; % flags which fixation point to use
    showDots = false;
    
    % task/trial parameters
    fixWinRadius@double;        % deg.
    fixGracePeriod@double;      % seconds
    fixHoldPreStim@double;      % seconds
    fixFlashCnt@double;         % frames
    fixHoldPostStim@double;     % seconds
    choiceHoldDuration@double;  % seconds
    choiceGracePeriod@double;   % seconds
    choiceDuration@double;      % seconds
    rewardWindow@double;        % 
    choiceTimeout@double;       % seconds
    trialTimeout@double;        % seconds
    iti@double;                 % inter-trial interval (seconds)
    maxRewardCnt@double;
    
    DotsRewarded@logical
    
    rewardCnt@double = 0;
    reward@double = []; % look-up table for reward schedule
  end
  
  methods (Access = public)
    function o = dotMotionTrial(hFix,hDots,hFace,hReward,varargin)
%         dotMotionTrial(hFix,hDots,hFace,hReward,varargin)

      o.hFix    = hFix;
      o.hDots   = hDots;
      o.hFace   = hFace;
      o.hReward = hReward;
      
      % initialize the @state object pool...
      o.addState(stimuli.dotselection.state0_FixWait(o));
      o.addState(stimuli.dotselection.state1_FixGracePeriod(o));
      o.addState(stimuli.dotselection.state2_FixPreStim(o));
      o.addState(stimuli.dotselection.state3_WaitForGo(o));
      o.addState(stimuli.dotselection.state4_Choice(o));
      o.addState(stimuli.dotselection.state5_HoldChoice(o));
      o.addState(stimuli.dotselection.state7_BreakFixTimeout(o));
      o.addState(stimuli.dotselection.state8_InterTrialInterval(o));
      
      % set initial state
      o.setState(0);      
      
      if nargin < 5
        return
      end
      
      % --- Parse arguments
      args = varargin;
      p = inputParser;

      p.StructExpand = true;
      p.addParameter('fixWinRadius',    NaN,    @(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('fixGracePeriod',  NaN,    @(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('fixHoldPreStim',  NaN,    @(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('fixFlashCnt',     NaN,    @(x) isscalar(x) && isreal(x)); % frames
      p.addParameter('fixHoldPostStim', NaN,    @(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('choiceHoldDuration',NaN,  @(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('choiceGracePeriod', NaN,  @(x) isscalar(x) && isreal(x)); 
      p.addParameter('rewardWindow',    NaN,    @(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('choiceTimeout',   NaN,    @(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('trialTimeout',    NaN,    @(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('iti',             NaN,    @(x) isscalar(x) && isreal(x)); % seconds
      
      p.addParameter('maxRewardCnt',NaN,@(x) isscalar(x) && isreal(x));
      
      p.addParameter('DotsRewarded',[false false]);
      p.addParameter('viewpoint',false,@islogical);
      
      p.parse(args{:});
      try
        p.parse(args{:});
      catch
        warning('Failed to parse name-value arguments.');
        return;
      end
      
      args = p.Results;
    
      o.fixWinRadius        = args.fixWinRadius;
      o.fixGracePeriod      = args.fixGracePeriod;
      o.fixHoldPreStim      = args.fixHoldPreStim;
      o.fixFlashCnt         = args.fixFlashCnt;
      o.fixHoldPostStim     = args.fixHoldPostStim;
      o.choiceHoldDuration  = args.choiceHoldDuration;
      o.choiceGracePeriod   = args.choiceGracePeriod;
      if isnan(o.choiceGracePeriod)
          o.choiceGracePeriod = o.fixGracePeriod;
      end
      o.rewardWindow        = args.rewardWindow;
      o.choiceTimeout       = args.choiceTimeout;
      o.trialTimeout        = args.trialTimeout;
      o.iti                 = args.iti;
            
      % maximum reward
      o.maxRewardCnt        = args.maxRewardCnt;
      
      % which dot target is rewarded?
      o.DotsRewarded        = args.DotsRewarded;
      
      % use viewpoint?
      o.viewpoint           = args.viewpoint;
      
      % how much reward to give throughout the trial
      o.reward              = o.maxRewardCnt;

    end
    

  end % methods
  
  methods (Static)
   
  end % static methods
  
end % classdef
