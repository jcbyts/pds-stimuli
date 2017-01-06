classdef dotMotionState5 < stimuli.state
  % state 5 - choice
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
  end
  
  methods (Access = public)
    function s = dotMotionState5(hTrial,varargin),
      fprintf(1,'dotMotionState5()\n');
      
      s = s@stimuli.state(5,hTrial); % call the parent constructor
    end
    
    function beforeFrame(s),
%       fprintf(1,'dotMotionState5.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      if hTrial.showChoice,
        hTrial.hChoice.beforeFrame();
      end
      
      if hTrial.showCue,
        hTrial.hCue(1).beforeFrame(); % draw cue
      end
    end
    
    function afterFrame(s,t),
%       fprintf(1,'dotMotionState5.afterFrame()\n');
      
      hTrial = s.hTrial;
      
      if isnan(s.tStart), % <-- first frame
        s.tStart = t;
      end
      
      if t < (s.tStart + hTrial.choiceGracePeriod),
        return;
      end
      
      if t > (hTrial.getTxTime(3) + hTrial.cueDelay),
        hTrial.showCue = true;
      end
     
      if t > (s.tStart + hTrial.choiceTimeout),
        % timed out... move to state 8 - inter-trial interval
        hTrial.error = 4;
        hTrial.setState(8);
        return;
      end

      r = norm([hTrial.x,hTrial.y]);

      if (r > hTrial.choiceWinMinRadius) && ...
         (r < hTrial.choiceWinMaxRadius),
        % move to state 6 - hold choice
        hTrial.setState(6);
        return;
      end
    end
    
  end % methods
  
end % classdef
