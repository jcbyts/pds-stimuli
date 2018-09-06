classdef state4_Choice < stimuli.objects.state
    % state 3 - motion is on
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state4_Choice(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(4); % call the parent constructor
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
            
            dotsxy = p.trial.behavior.eyeAtFrame(:,p.trial.(sn).frameFixDim:p.trial.iFrame);
            Screen('DrawDots', p.trial.display.overlayptr, dotsxy, 4, p.trial.display.clut.eyepos, [], 0);
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % track eye position wrt fixation
            s.eyeXY = [p.trial.eyeX p.trial.eyeY] - p.trial.(sn).fixation.hFix.position;
            s.eyeXY = s.eyeXY .* [1 -1]; % flip y axis (because pixels run down)

            % update motion
            p.trial.(sn).motion.hMot.frameUpdate(p);

            % check when stimuli need to be turned off
            frameTurnOffMotion   = p.trial.(sn).frameMotionTurnedOn + ceil(p.trial.(sn).timing.t_stimDuration / p.trial.display.ifi);
            frameTurnOffFixation = p.trial.(sn).frameMotionTurnedOn + ceil(p.trial.(sn).timing.t_fixPostStimDuration / p.trial.display.ifi);

            
            if p.trial.iFrame >= frameTurnOffMotion
              p.trial.(sn).motion.hMot.stimValue = 0;
              p.trial.(sn).frameMotionTurnedOff = p.trial.iFrame;
            end

            if p.trial.iFrame >= frameTurnOffFixation
              p.trial.(sn).fixation.hFix.stimValue = 0;
              p.trial.(sn).frameFixationTurnedOff = p.trial.iFrame;
            end

            % this state ends when the period of required fixation is over
            frameStopWaitForChoice = p.trial.(sn).frameFixDim + ceil(p.trial.(sn).timing.choiceWaitTimeout / p.trial.display.ifi);

            if p.trial.iFrame > frameStopWaitForChoice

              % transition states
              sc.setState(6); % transition to feedback
              return
            end

            % check if choice was made
            r = sqrt(sum(s.eyeXY.^2)); % euclidean distance
            if r > (p.trial.(sn).targets.windowMinEcc * p.trial.display.ppd) && ...
              r < (p.trial.(sn).targets.windowMaxEcc * p.trial.display.ppd)
              
              p.trial.(sn).frameChoiceMade = p.trial.iFrame;

              sc.setState(5);
            end





        end
        
        
    end % methods
    
end % classdef