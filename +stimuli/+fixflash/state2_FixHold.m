classdef state2_FixHold < stimuli.state
  % state 2 - hold fixation for reward
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
    eyeXY
  end
  
  methods (Access = public)
    function s = state2_FixHold(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(2,hTrial); % call the parent constructor      
    end
    
    function beforeFrame(s)
%       fprintf(1,'dotMotionState2.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      if hTrial.showFix
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      end
    end
    
    function afterFrame(s,t)
            
      hTrial = s.hTrial;
      
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
        s.eyeXY = [hTrial.x,hTrial.y];
        hTrial.setTxTime(t); % save transition time
      end
      
      if t > (s.tStart + hTrial.fixDuration)
        pds.behavior.reward.give(hTrial.hPldaps) % reward for fixation! (TODO: amount)
        hTrial.holdXY = mean(s.eyeXY);
        hTrial.rewardCnt=hTrial.reward;
        % move to state 8 - inter-trial interval
        hTrial.setState(8);
        return;
      end
      
      r = norm([hTrial.x,hTrial.y]);
      
      s.eyeXY = [s.eyeXY; [hTrial.x hTrial.y]];
      
      if (r > hTrial.fixWinRadius)
        % broke fixation... move to state 7 - timeout
        hTrial.holdXY = mean(s.eyeXY);
        hTrial.error = 2;
        hTrial.setState(7)
        return;
      end
    end
    
  end % methods

end % classdef