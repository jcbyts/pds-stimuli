classdef gratingForageTrial < stimuli.trial
  % @trial class for the grating forage task
  
  % 17-03-2017 <jacoby8s@gmail.com>
  
  properties
    trialNum@double = 0;
    
    done@logical = false; % true when trial is complete
        
    x; % gaze position (pix.)
    y; % gaze position (pix.)
    
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
    hGratings@handle;
    hFace@handle;
    hReward@handle;
    hNoise@handle;
    
    % flags
    showGratings = true;
    
    % task/trial parameters
    fixWinRadius@double;        % pixels
    fixGracePeriod@double;      % seconds
    
    fixDuration@double;         % seconds
    
    trialTimeout@double;        % seconds
    iti@double;                 % inter-trial interval (seconds)
    
    rewardCnt@double = 0;
    rewardAmount@double;
    
    rng@RandStream;

  end

  properties (Access = public)
    reward@double = []; % look-up table for reward schedule
    bonus@double  = []; % look-up table for bonus schedule
  end
  
  methods (Access = public)
    function o = gratingForageTrial(setupRNG,hGratings,hNoise,hFace,hReward,varargin)
      o.rng         = setupRNG;
      o.hGratings   = hGratings;
      o.hFace       = hFace;
      o.hReward     = hReward;
      o.hNoise      = hNoise;
      
      % initialise the @state object pool...
      o.addState(stimuli.gratingForage.state0_Forage(o));
      o.addState(stimuli.gratingForage.state1_Fixed(o));
      o.addState(stimuli.gratingForage.state8_ITI(o));   
      
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
      p.addParameter('fixDuration',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      
      p.addParameter('trialTimeout',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      p.addParameter('iti',NaN,@(x) isscalar(x) && isreal(x)); % seconds
      
      
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
      o.trialTimeout        = args.trialTimeout;
      o.iti                 = args.iti;
      
      o.reward              = 0;
      o.rewardCnt           = 0;

    end
    
  end % methods
  
  methods (Static)
   
  end % static methods
  
end % classdef
