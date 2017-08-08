classdef state4_WaitForGo < stimuli.state
  % state 3 - hide stimulus/hold fixation
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
  end
  
  methods (Access = public)
    function s = state4_WaitForGo(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(4,hTrial); % call the parent constructor      
    end
    
    function beforeFrame(s)
%       fprintf(1,'dotMotionState4.beforeFrame()\n');
      
      hTrial = s.hTrial;
      hTrial.hFix(1).beforeFrame(); % draw fixation target
      
      if hTrial.showDots
          for k = 1:2
             hTrial.hDots(k).beforeFrame(); 
          end 
      end
      
    end
    
    function afterFrame(s,t)
%       fprintf(1,'dotMotionState4.afterFrame()\n');
      
      hTrial = s.hTrial;
      
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
      end
      
      if hTrial.showDots
          for k = 1:2
             hTrial.hDots(k).afterFrame(); 
          end 
      end
      
      if t > (hTrial.getTxTime(3) + hTrial.holdDuration)
        % move to state 5 - choice
        hTrial.setState(5);
        return;
      end        
      
      r = norm([hTrial.x,hTrial.y]);
      
      if (r > hTrial.fixWinRadius)
        % broke fixation... move to state 7 - timeout
        hTrial.error = 3;
        hTrial.setState(7);
        return;
      end
      
    end
    
  end % methods
  
end % classdef