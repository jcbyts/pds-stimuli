classdef state2_FixPreStim < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state2_FixPreStim(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(2); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(s,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).fixation.hFix.frameDraw(p);
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;

            % detect break fixations
            if ~p.trial.(sn).fixation.hFix.isFixated
                sc.setState(7);
                return
            end
            
            % check if fixation has been obtained
            if isnan(p.trial.(sn).frameFixationObtained) && p.trial.(sn).fixation.hFix.isFixated
                p.trial.(sn).frameFixationObtained = p.trial.iFrame;
            end
            
            % check if time to show the targets
            timeToShowTargs = p.trial.(sn).frameFixationObtained + ceil(p.trial.(sn).timing.t_targetOnset / p.trial.display.ifi);
            if p.trial.iFrame >= timeToShowTargs
                p.trial.(sn).targets.hTarg.stimValue = 1; % targets on
            end

            timeToShowMotion = p.trial.(sn).frameFixationObtained + ceil(p.trial.(sn).timing.t_fixPreStimDuration / p.trial.display.ifi);
            
            
            % time to move to next state?
            if p.trial.iFrame >= timeToShowMotion
                
                if p.trial.(sn).fixation.rewardForFixation
                    pds.behavior.reward.give(p)
                end
                
                % fixPos = p.trial.(sn).fixation.hFix.position; % in pixels
                
                % turn on the motion stimulus
                p.trial.(sn).motion.hMot.stimValue = true;
                p.trial.(sn).frameMotionTurnedOn = p.trial.iFrame;
                                
                % transition states
                sc.setState(3);
                return
            end
        end
        
        
    end % methods
    
end % classdef