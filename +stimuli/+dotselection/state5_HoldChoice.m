classdef state5_HoldChoice < stimuli.state
  % state 5 - hold choice
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
    
    choice      = 0;
    choiceX     = 0;
    choiceY     = 0;
    frameCnt    = 0;
  end
  
  methods (Access = public)
    function s = state5_HoldChoice(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(5,hTrial); % call the parent constructor
    end
    
    function beforeFrame(s)
%       fprintf(1,'dotMotionState6.beforeFrame()\n');
      
      hTrial = s.hTrial;
      
      if hTrial.showChoice
        hTrial.hChoice.beforeFrame();
      end
      
      if hTrial.showCue
        hTrial.hCue(1).beforeFrame(); % draw cue
      end
    end
    
    function afterFrame(s,t)
%       fprintf(1,'dotMotionState6.afterFrame()\n');
      
      hTrial = s.hTrial;
      
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
      end
      
      if t > (s.tStart + hTrial.choiceHoldDuration)
        % trial complete... move to state 8 - reward/inter-trial interval
        
        hTrial.rewardCnt = hTrial.maxRewardCnt * hTrial.DotsRewarded(hTrial.Choice);
%         % record the choice eye position
%         hTrial.choiceX = mean(s.choiceX);
%         hTrial.choiceY = mean(s.choiceY);
        hTrial.setState(8);
        return;
      end
      
      r = norm([hTrial.x - hTrial.hDots(hTrial.Choice).position(1), hTrial.y - hTrial.hDots(hTrial.Choice).position(2)]);
      
      if r > hTrial.rewardWindow + hTrial.hDots(hTrial.Choice).maxRadius
        % failed to hold choice... move to state 7 - break fix penalty
        hTrial.error = 5;
        hTrial.setState(7);
        return;
      end
           
      % record the choice (will average over all frames)
      s.frameCnt = s.frameCnt+1;
      s.choiceX(s.frameCnt) = hTrial.x;
      s.choiceY(s.frameCnt) = hTrial.y;
    end
    
  end % methods
end % classdef