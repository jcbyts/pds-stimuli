classdef state8_InterTrialInterval < stimuli.state
    % state 8 - inter-trial interval
    
    % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
    
    properties
        tStart    = NaN;    % 'start' time
        rewardCnt = 0;      % the number of reward(s) delivered...
        showFace  = true;  % show face, for additional reward?
    end
    
    methods (Access = public)
        function s = state8_InterTrialInterval(hTrial,varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(8,hTrial); % call the parent constructor
        end
        
        function beforeFrame(s)
            
            hTrial = s.hTrial;
            
%             if hTrial.rewardCnt > 0
%                 s.showFace = true;
%             end
            
            if s.showFace
                hTrial.hFace.beforeFrame(); % show face...
%             else
%                 hTrial.hFbk.beforeFrame();  % draw the *correct* choice cue
            end
        end % beforeFrame
        
        function afterFrame(s,t)
            
            hTrial = s.hTrial;
            
            if isnan(s.tStart) % <-- first frame
                s.tStart = t;
                hTrial.setTxTime(t);
                hTrial.rewardAmount = 1+find(hTrial.holdDuration>hTrial.rewardLevels, 1, 'last'); % round(2*hTrial.holdDuration.^1.2);
                fprintf('Reward amount: %d\n', hTrial.rewardAmount)
            end
            
            if t > s.tStart + hTrial.rewardFaceDuration
                s.showFace = false;
            end
            
            if s.rewardCnt < hTrial.rewardAmount
                if t > (s.tStart + 0.2*s.rewardCnt)

                    hTrial.hReward.give();
                    
                    s.rewardCnt = s.rewardCnt + 1;
                end
            elseif (t > (s.tStart + hTrial.iti))
                % done...
                hTrial.done = true;
                return;
            end
            
            
        end % afterFrame
        
    end % methods
    
end % classdef
