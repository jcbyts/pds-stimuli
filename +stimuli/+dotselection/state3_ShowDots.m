classdef state3_ShowDots < stimuli.state
  % state 3 - show dots
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN; % start of THIS state
  end
  
  methods (Access = public)
    function s = state3_ShowDots(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(3,hTrial); % call the parent constructor      
    end
    
    function beforeFrame(s)
%       fprintf(1,'dotMotionState3.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      for k = 1:2
        hTrial.hDots(k).beforeFrame(); % draw random dot pattern
      end

      if hTrial.showFix
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      else
        hTrial.hFix(2).beforeFrame();
      end
      
    end
    
    function afterFrame(s,t)
%       fprintf(1,'dotMotionState3.afterFrame()\n');
            
      hTrial = s.hTrial;
      
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
      end
      
      % move dots...
      for k = 1:2
        hTrial.hDots(k).afterFrame();
      end
      
      if t > (s.tStart + hTrial.holdDuration)
        hTrial.showFix = false;
      end
            
      if t > (s.tStart + hTrial.stimDuration)
        if hTrial.showFix
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
      
      if (r > hTrial.fixWinRadius)
        if hTrial.showFix
          % broke fixation... move to state 7 - timeout
          hTrial.error = 3;
          hTrial.setState(7);
          return;
        else
          % move to state 5 - choice
          hTrial.setState(5);
          return;
        end
      end
      
    end
    
  end % methods

end % classdef