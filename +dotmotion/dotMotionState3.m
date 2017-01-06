classdef dotMotionState3 < stimuli.state
  % state 3 - show stimulus
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
  end
  
  methods (Access = public)
    function s = dotMotionState3(hTrial,varargin),
      fprintf(1,'dotMotionState3()\n');
      
      s = s@stimuli.state(3,hTrial); % call the parent constructor      
    end
    
    function beforeFrame(s),
%       fprintf(1,'dotMotionState3.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      hTrial.hDots.beforeFrame(); % draw random dot pattern

      if hTrial.showFix,
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      else,
        hTrial.hFix(2).beforeFrame();
      end
      
      if hTrial.showChoice,
        hTrial.hChoice.beforeFrame();
      end
      
      if hTrial.showCue,
        hTrial.hCue(1).beforeFrame(); % draw cue
      end
    end
    
    function afterFrame(s,t),
%       fprintf(1,'dotMotionState3.afterFrame()\n');
            
      hTrial = s.hTrial;
      
      if isnan(s.tStart), % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
      end
      
      if t > (s.tStart + hTrial.cueDelay),
        hTrial.showCue = true;
      end
      
      % move dots...
      hTrial.hDots.afterFrame();
      
      if t > (s.tStart + hTrial.holdDuration),
        hTrial.showFix = false;
      end
            
      if t > (s.tStart + hTrial.stimDuration),
        if hTrial.showFix,
          % holdDuration is > stimDuration, move to state 4 - hide stimulus/hold fixation
          hTrial.setState(4);
          return;
        else
          % holdDuration is < stimDuration, move to state 5 - choice
          hTrial.setState(5);
          return;
        end
      end  
      
      r = norm([hTrial.x,hTrial.y]);
      
      if (r > hTrial.fixWinRadius),
        if hTrial.showFix,
          % broke fixation... move to state 7 - timeout
          hTrial.error = 3;
          hTrial.setState(7);
          return;
        else,
          % move to state 5 - choice
          hTrial.setState(5);
          return;
        end
      end
      
    end
    
  end % methods

end % classdef