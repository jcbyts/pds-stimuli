classdef state3_WaitForGo < stimuli.state
  % state 3 - show dots and wait for go signal
  
  % 11-08-2017 Jacob L. Yates   wrote it
  
  properties
    tStart = NaN; % start of THIS state
  end
  
  methods (Access = public)
    function s = state3_WaitForGo(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(3,hTrial); % call the parent constructor      
    end
    
    function beforeFrame(s)
%       fprintf(1,'dotMotionState3.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      if hTrial.showDots
          for k = 1:2
              hTrial.hDots(k).beforeFrame(); % draw random dot pattern
          end
      end

      if hTrial.showFix
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      else
        hTrial.hFix(2).beforeFrame();
      end
      
    end
    
    function afterFrame(s,t)
            
      hTrial = s.hTrial;
      
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
      end
      
      % move dots...
      if hTrial.showDots
        for k = 1:2
            hTrial.hDots(k).afterFrame();
        end
      end
      
      if t > (s.tStart + hTrial.fixHoldPostStim)
         hTrial.showFix = false;
         hTrial.setState(4);
         return
      end
                 
      r = norm([hTrial.x,hTrial.y]);
      
      if (r > hTrial.fixWinRadius)
          % broke fixation... move to state 7 - timeout
          hTrial.error = 3;
          hTrial.setState(7);
          return
      end
      
    end
    
  end % methods

end % classdef