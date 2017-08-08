classdef state8_InterTrialInterval < stimuli.state
  % state 8 - inter-trial interval
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN; % 'start' time
    
    rewardCnt = 0; % the number of reward(s) delivered...
    
    showFace = false; % show face, for additional reward?
    
    plotFlag = false; % urgh! true after we've updated the gui
  end
  
  methods (Access = public)
    function s = state8_InterTrialInterval(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(8,hTrial); % call the parent constructor
    end
    
    function beforeFrame(s)
%       fprintf(1,'dotMotionState8.beforeFrame()\n');
      
      hTrial = s.hTrial;

      if hTrial.rewardCnt > 0
        s.showFace = true;
      end

      if hTrial.showChoice
        hTrial.hChoice.beforeFrame();
      end
      
      if s.showFace
        hTrial.hFace.beforeFrame(); % show face...
      else
        hTrial.hCue.beforeFrame(); % draw the *correct* choice cue
      end
    end
    
    function afterFrame(s,t)
%       fprintf(1,'dotMotionState8.afterFrame()\n');
      
      hTrial = s.hTrial;
          
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
      end

      if (hTrial.rewardCnt > 0)
        if t > (s.tStart + 0.2*s.rewardCnt)
%           hTrial.hReward.deliver();
          pds.behavior.reward.give(hTrial.hPldaps)

          s.rewardCnt = s.rewardCnt + 1;
          
          fprintf(1,'dotMotionTrial.rewardCnt = %i\n',hTrial.rewardCnt);
          hTrial.rewardCnt = hTrial.rewardCnt - 1;
        end
      end
      
      if (hTrial.rewardCnt <= 0)
        if (t > (s.tStart + hTrial.iti))
          % done...
          hTrial.done = true;
          return;
        end
      end

%       % FIXME: Urgh!
%       if ~s.plotFlag,
% %         eval(hTrial.A.plotCmd);
%         s.plotFlag = true;
%         
%         if hTrial.viewpoint,
%           vpx_SendCommandString(sprintf('dataFile_InsertString "TRIALEND:TRIALNO:%i"',hTrial.trialNum));
%         end
%       end
    end
    
  end % methods
  
end % classdef
