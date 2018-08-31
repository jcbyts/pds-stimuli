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
        function frameDraw(s)
            
            s.sc.hTargs.frameDraw();
            s.sc.hFace.frameDraw();
            s.sc.hErr.frameDraw();

%             if ~isnan(sc.choice)
%                 xy = [sc.choiceX sc.choiceY*-1];
%                 Screen('DrawDots', s.sc.hTargs.ptr, xy, 10, p.trial.display.clut.targetnull, p.trial.display.ctr(1:2), 2);
%             end
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s)
            
            % get the state controller ready
            sc = s.sc;
            
            % --- Time to transition to next state if fixation is held

            if isnan(s.rewardToGive)
                s.rewardToGive = sc.rewardFun(sc.error);
                if isnan(s.rewardToGive)
                    s.rewardToGive = 0;
                end
            end

            if s.rewardToGive == 0
                sc.hErr.stimValue = 1;
            else
                sc.hFace.stimValue = 1;
            end


            if s.rewardCnt < s.rewardToGive && (mod(sc.iFrame, s.rewardInterval)==0)
%                 pds.behavior.reward.give(p, p.trial.(sn).reward.amount)
                s.rewardCnt = s.rewardCnt + 1;
            else
               sc.setState(8);    
            end 
            
            
            
      
        end
        
        
    end % methods
    
end % classdef