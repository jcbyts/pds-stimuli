classdef dotMotionState6 < stimuli.state
  % state 5 - hold choice
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
    
    choice = 0;
    frameCnt = 0;
  end
  
  methods (Access = public)
    function s = dotMotionState6(hTrial,varargin),
      fprintf(1,'dotMotionState6()\n');
      
      s = s@stimuli.state(6,hTrial); % call the parent constructor
    end
    
    function beforeFrame(s),
%       fprintf(1,'dotMotionState6.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      if hTrial.showChoice,
        hTrial.hChoice.beforeFrame();
      end
      
      if hTrial.showCue,
        hTrial.hCue(1).beforeFrame(); % draw cue
      end
    end
    
    function afterFrame(s,t),
%       fprintf(1,'dotMotionState6.afterFrame()\n');
      
      hTrial = s.hTrial;
      
      if isnan(s.tStart), % <-- first frame
        s.tStart = t;
      end
      
%       if t > (s.tStart + hTrial.choiceTargetDelay - max(hTrial.stimDuration,hTrial.holdDuration) - hTrial.gracePeriod),
      if t > (hTrial.getTxTime(3) + hTrial.cueDelay),
        hTrial.showCue = true;
      end
      
      if t > (s.tStart + hTrial.choiceDuration),
        % trial complete... move to state 8 - reward/inter-trial interval

        % record the choice direction... circular mean
        hTrial.choice = mod(angle(nansum(exp(1i*s.choice(:))))*(180/pi),360); % note: s.choice is in radians!

        % calculate reward...
        direction = hTrial.hDots.direction;
        
        error = mod(hTrial.choice - direction,360);
      
        idx = round(error) + 1;
        hTrial.rewardCnt = round(hTrial.reward(idx));

        % bonus reward... to correct for spatial choice bias...
        idx = round(direction) + 1;
        hTrial.rewardCnt = hTrial.rewardCnt + round(hTrial.bonus(idx));
        
        hTrial.setState(8);
        return;
      end
      
%       r = norm([hTrial.x,hTrial.y]);
      [th,r] = cart2pol(hTrial.x,hTrial.y);

      if (r < hTrial.choiceWinMinRadius) || ...
         (r > hTrial.choiceWinMaxRadius),
        % failed to hold choice... move to state 8 - inter-trial interval
        hTrial.error = 5;
        hTrial.setState(8);
        return;
      end
           
      % record the choice direction (will average over all frames)
      s.frameCnt = s.frameCnt+1;
      s.choice(s.frameCnt) = th; % note: radians!      
    end
    
  end % methods
end % classdef