classdef fixFlashTrial < stimuli.trial
  % @trial class for the fix flash task
  
  % 17-03-2017 <jacoby8s@gmail.com>
  
  properties
    trialNum@double = 0;
    
    done@logical = false; % true when trial is complete
        
    x; % gaze position (deg.)
    y;
    
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
    hFbk@handle;
    hFace@handle;
    hReward@handle;
    
    % trial objects
    viewpoint@logical = false;
    
    
    % flags...?
    showFix = true;
    showCue = false;
    showChoice = true; % FIXME: true?
    
    % task/trial parameters
    fixWinRadius@double;        % deg.
    fixGracePeriod@double;      % seconds
    
    minFixation@double
    maxFixation@double
    
    fixDuration@double;         % seconds
    fixFlashCnt@double;         % frames
    holdDuration@double;        % seconds
    trialTimeout@double;        % seconds
    iti@double;                 % inter-trial interval (seconds)
    rewardForObtainFixation     % flag (reward for obtaining fixation)
    rewardFaceDuration
    
    maxRewardCnt@double;
    
    holdXY
    
    rewardCnt@double = 0;
    rewardAmount@double;

  end

  properties (Access = public)
    reward@double = []; % look-up table for reward schedule
    bonus@double  = []; % look-up table for bonus schedule
  end
  
  methods (Access = public)
    function o = fixFlashTrial(hFix,hFbk,hFace,hReward,varargin)
      o.hFix    = hFix;
      o.hFbk    = hFbk;
      o.hFace   = hFace;
      o.hReward = hReward;
      
      % initialise the @state object pool...
      o.addState(stimuli.fixflash.state0_FixWait(o));
      o.addState(stimuli.fixflash.state1_FixGracePeriod(o));
      o.addState(stimuli.fixflash.state2_FixHold(o));
      o.addState(stimuli.fixflash.state7_BreakFixTimeout(o));
      o.addState(stimuli.fixflash.state8_InterTrialInterval(o));    
      
      % set initial state
      o.setState(0);      
      
      if nargin < 4
        return
      end
      
      % initialise input parser
      args = varargin;
      p = inputParser;

      p.StructExpand = true;
      p.addParameter('fixWinRadius',NaN,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('fixGracePeriod',NaN,@(x) isscalar(x) && isreal(x)); % seconds
%       p.addParameter('fixDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('minFixation',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('maxFixation',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('fixFlashCnt',NaN,@(x) isscalar(x) && isreal(x)); % frames
      p.addParameter('holdDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('trialTimeout',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('iti',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('rewardForObtainFixation', false)
      p.addParameter('rewardFaceDuration', .5)
      p.addParameter('maxRewardCnt',NaN,@(x) isscalar(x) && isreal(x));
      
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
%       o.fixDuration         = args.fixDuration;
      o.minFixation         = args.minFixation;
      o.maxFixation         = args.maxFixation;
      o.fixFlashCnt         = args.fixFlashCnt;
      o.holdDuration        = args.holdDuration;
      o.trialTimeout        = args.trialTimeout;
      o.iti                 = args.iti;
      o.rewardFaceDuration  = args.rewardFaceDuration;
            
      o.maxRewardCnt        = args.maxRewardCnt;
      o.rewardForObtainFixation = args.rewardForObtainFixation;
           
      o.viewpoint           = args.viewpoint;
      
      o.holdXY = nan(1,2);
      o.reward = o.maxRewardCnt;

    end
    
%     function d = report(o),
%       d = struct('rndState',o.rndState);
%     end
  end % methods
  
  methods (Static)
   
  end % static methods
  
end % classdef
