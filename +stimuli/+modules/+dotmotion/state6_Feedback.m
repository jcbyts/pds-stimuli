classdef state6_Feedback < stimuli.objects.state
    % state 2 - choose targets
    
    properties
        rewardCnt = 0; % the number of reward(s) delivered...
        rewardToGive = nan
        rewardInterval = 5; % frames
    end
    
    methods (Access = public)
        function s = state6_Feedback(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(6); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            p.trial.(sn).targets.hTargs.frameDraw(p);
            p.trial.(sn).feedback.hFace.frameDraw(p);
            p.trial.(sn).feedback.hErr.frameDraw(p);

            if ~isnan(p.trial.(sn).choice)
                xy = [p.trial.(sn).choiceX p.trial.(sn).choiceY*-1];
                Screen('DrawDots', p.trial.display.overlayptr, xy, 10, p.trial.display.clut.targetnull, p.trial.display.ctr(1:2), 2);
            end
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % --- Time to transition to next state if fixation is held
            startTime = sc.getTxTime(s.id) - p.trial.trstart;

            if isnan(s.rewardToGive)
                s.rewardToGive = p.trial.(sn).reward.function(p.trial.(sn).error, p.trial.(sn).reward.windowWidth, p.trial.(sn).reward.maxNumber);
                if isnan(s.rewardToGive)
                    s.rewardToGive = 0;
                end
            end

            if s.rewardToGive == 0
                p.trial.(sn).feedback.hErr.stimValue = 1;
            else
                p.trial.(sn).feedback.hFace.stimValue = 1;
            end


            if s.rewardCnt < s.rewardToGive && (mod(p.trial.iFrame, s.rewardInterval)==0)
                pds.behavior.reward.give(p, p.trial.(sn).reward.amount)
                s.rewardCnt = s.rewardCnt + 1;
            else
               sc.setState(8);    
            end 
            
            
            
      
        end
        
        
    end % methods
    
end % classdef