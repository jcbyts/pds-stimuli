classdef state3_ShowMotion < stimuli.objects.state
    % state 3 - motion is on
    
    properties
    end
    
    methods (Access = public)
        function s = state3_ShowMotion(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(3); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).fixation.hFix.frameDraw(p);
            % draw targets
            p.trial.(sn).targets.hTargs.frameDraw(p);
            % draw motion
            p.trial.(sn).motion.hMot.frameDraw(p);
            % draw cue
            p.trial.(sn).cue.hCue.frameDraw(p);
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % update motion
            p.trial.(sn).motion.hMot.frameUpdate(p);
            
            % check when stimuli need to be turned off
            frameTurnOffMotion   = p.trial.(sn).frameMotionTurnedOn + ceil(p.trial.(sn).timing.t_stimDuration / p.trial.display.ifi);
            frameTurnOnCue       = p.trial.(sn).frameMotionTurnedOn + ceil(p.trial.(sn).timing.t_cueOnset / p.trial.display.ifi);
            frameTurnOffFixation = p.trial.(sn).frameMotionTurnedOn + ceil(p.trial.(sn).timing.t_fixPostStimDuration / p.trial.display.ifi);
            frameStopFixationHold  = p.trial.(sn).frameMotionTurnedOn + ceil(p.trial.(sn).timing.fixHoldDuration / p.trial.display.ifi);
            
            % detect break fixations (fixation must be held during this state)
            if ~p.trial.(sn).fixation.hFix.isFixated
                sc.setState(7);
                return
            end
            
            % check if time to show the targets
            timeToShowTargs = p.trial.(sn).frameFixationObtained + ceil(p.trial.(sn).timing.t_targetOnset / p.trial.display.ifi);
            if p.trial.iFrame >= timeToShowTargs
                p.trial.(sn).targets.hTarg.stimValue = 1; % targets on
            end
            
            % time to move to next state?
            if p.trial.iFrame >= frameTurnOffMotion
                p.trial.(sn).motion.hMot.stimValue = 0;
                p.trial.(sn).frameMotionTurnedOff = p.trial.iFrame;
            end
            
            if p.trial.iFrame >= frameTurnOnCue
                p.trial.(sn).cue.hCue.stimValue = 1;
                p.trial.(sn).frameCueTurnedOn = p.trial.iFrame;
            end
            
            if p.trial.iFrame >= frameTurnOffFixation
                p.trial.(sn).fixation.hFix.stimValue = 0;
                p.trial.(sn).frameFixationTurnedOff = p.trial.iFrame;
            end
            
            % this state ends when the period of required fixation is over
            if p.trial.iFrame >= frameStopFixationHold
                p.trial.(sn).fixation.hFix.color = p.trial.display.clut.fixSurColorDim;
                p.trial.(sn).fixation.hFix.ctrColor = p.trial.display.clut.fixCtrColorDim;
                p.trial.(sn).fixation.hFix.wincolor = []; % window off, no fixation requirement
                p.trial.(sn).frameFixDim = p.trial.iFrame;
                
                % transition states
                sc.setState(4); % transition to wait for choice
                return
            end
            
            
        end
        
        
    end % methods
    
end % classdef