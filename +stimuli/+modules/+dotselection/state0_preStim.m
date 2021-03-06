classdef state0_preStim < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state0_preStim(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(0); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,~,~)
            
            % no drawing i nthis state
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % fieldname for the fixation behavior
            fixSn  = p.trial.(sn).fixationBehavior;
            
            % check if fixation has been obtained
            if isnan(p.trial.(sn).frameFixationObtained) && p.trial.(fixSn).hFix.isFixated
                p.trial.(sn).frameFixationObtained = p.trial.iFrame;
            end
            
            timeToShow = p.trial.(sn).frameFixationObtained + p.trial.(sn).preStimWaitFrames;
            
            
            if p.trial.iFrame >= timeToShow
                
                if p.trial.(sn).rewardForFixation
                    pds.behavior.reward.give(p)
                end
                
                % update the position of the dots (relative to fixation
                % point)
                fixPos = p.trial.(fixSn).hFix.position; % in pixels
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
                
                % update fixation behavior to be relative to fixation
                % obtained
                p.trial.(p.trial.(sn).fixationBehavior).fixStartOffset = p.trial.ttime;
                
                % transition states
                sc.setState(1);
                return
            end
        end
        
        
    end % methods
    
end % classdef