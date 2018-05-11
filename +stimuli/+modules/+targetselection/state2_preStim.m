classdef state2_preStim < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state2_preStim(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(2); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(s,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).hFix.frameDraw(p);
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % check if fixation has been obtained
            if isnan(p.trial.(sn).frameFixationObtained) && p.trial.(sn).hFix.isFixated
                p.trial.(sn).frameFixationObtained = p.trial.iFrame;
            end
            
            timeToShow = p.trial.(sn).frameFixationObtained + p.trial.(sn).preStimWaitFrames;
            
            % detect break fixations
            if ~p.trial.(sn).hFix.isFixated
                sc.setState(7);
                return
            end
            
            % time to move to next state?
            if p.trial.iFrame >= timeToShow
                
                if p.trial.(sn).rewardForFixation
                    pds.behavior.reward.give(p)
                end
                
                % update the position of the dots (relative to fixation
                % point)
                fixPos = p.trial.(sn).hFix.position; % in pixels
                for k = 1:numel(p.trial.(sn).hTargs)
                    tmp_ = p.trial.(sn).hTargs(k).position;
                    tmp_ = tmp_ - p.trial.display.ctr(1:2);
                    
                    p.trial.(sn).hTargs(k).position = tmp_ + fixPos;
                    
                    % turn on the dots, with given contrast 0 to 1 by stimVis
                    if (p.trial.(sn).stimVisible(k) > 0)
                       p.trial.(sn).hTargs(k).stimValue = true;
                       p.trial.(sn).hTargs(k).contrast = ...
                             ( p.trial.(sn).stimVisible(k) * p.trial.(sn).contrast);
                    else
                       p.trial.(sn).hTargs(k).stimValue = false; 
                    end
                end
                                
                % transition states
                sc.setState(3);
                return
            end
        end
        
        
    end % methods
    
end % classdef