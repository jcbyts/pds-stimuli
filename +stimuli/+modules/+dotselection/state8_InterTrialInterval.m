classdef state8_InterTrialInterval < stimuli.objects.state
    % state 8 - inter-trial interval
    
    properties
        tStart    = NaN;    % 'start' time
        rewardCnt = 0;      % the number of reward(s) delivered...
    end
    
    methods (Access = public)
        function s = state8_InterTrialInterval(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(8); % call the parent constructor
        end
        
        function frameDraw(~,p,sn)
            
             p.trial.(sn).hFace.frameDraw(); % show face
            
        end % beforeFrame
        
        function frameUpdate(s,p,sn)
            
            sc = s.sc;
            
            if isnan(s.tStart) % <-- first frame
                s.tStart = sc.getTxTime(s.id) - p.trial.trstart;
                p.trial.(sn).error = 0;
                fprintf('Reward amount: %d\n', p.trial.(sn).rewardAmount)
            end
            
            if p.trial.ttime > s.tStart + p.trial.(sn).rewardFaceDuration
                p.trial.(sn).hFace.stimValue = false;
            end
            
            if s.rewardCnt < p.trial.(sn).rewardAmount
                if p.trial.ttime > (s.tStart + 0.2*s.rewardCnt)

                    pds.behavior.reward.give(p);
                    
                    s.rewardCnt = s.rewardCnt + 1;
                end
            elseif p.trial.ttime > (s.tStart + p.trial.(sn).iti)
                % done...
                p.trial.flagNextTrial = true;
                return
            end
            
            
        end % afterFrame
        
    end % methods
    
end % classdef
