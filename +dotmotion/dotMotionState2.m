classdef dotMotionState2 < stimuli.state
  % state 2 - hold fixation
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
  end
  
  methods (Access = public)
    function s = dotMotionState2(hTrial,varargin),
      fprintf(1,'dotMotionState2()\n');
      
      s = s@stimuli.state(2,hTrial); % call the parent constructor      
    end
    
    function beforeFrame(s),
%       fprintf(1,'dotMotionState2.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      if hTrial.showFix,
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      end
    end
    
    function afterFrame(s,t),
%       fprintf(1,'dotMotionState2.afterFrame()\n');
            
      hTrial = s.hTrial;
      
      if isnan(s.tStart), % <-- first frame
        s.tStart = t;
      end
      
      if t > (s.tStart + hTrial.fixDuration),
        hTrial.hReward.deliver(); % reward for fixation!

        % move to state 3 - show stimulus
        hTrial.setState(3);
        return;
      end
      
      r = norm([hTrial.x,hTrial.y]);
      
      if (r > hTrial.fixWinRadius),
        % broke fixation... move to state 7 - timeout
        hTrial.error = 2;
        hTrial.setState(7)
        return;
      end
    end
    
  end % methods

end % classdef