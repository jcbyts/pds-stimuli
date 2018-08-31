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
        function frameDraw(s)
            
            % call draw functions for objects that should be shown
            s.sc.hFix.frameDraw();
            % draw targets
            s.sc.hTargs.frameDraw();
            % draw motion
            s.sc.hMot.frameDraw();
            % draw cue
            s.sc.hCue.frameDraw();
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s)
            
            % get the state controller ready
            sc = s.sc;
            
            % track eye position wrt fixation
            s.eyeXY = sc.eyeXY - sc.hFix.position;
            s.eyeXY = s.eyeXY .* [1 -1]; % flip y axis (because pixels run down)

            % update motion
            sc.hMot.frameUpdate();

            % time to turn off motion
            if sc.iFrame >= (sc.timeMotionTurnedOn + sc.timeMotionOffset)
                sc.hMot.stimValue = 0;
                sc.timeMotionTurnedOff = sc.iFrame;
            end

            % time to turn off fixation
            if sc.iFrame >= (sc.timeFixationObtained + sc.timeFixationOffset)
                sc.hFix.stimValue = 0;
                sc.timeFixationTurnedOff = sc.iFrame;
            end

            % this state ends when the period of required fixation is over
            if sc.iFrame > (sc.timeFixDim + sc.timeWaitForChoice)
                
                % transition states
                sc.setState(6); % transition to feedback
                return
            end

            % check if choice was made
            r = sqrt(sum(s.eyeXY.^2)); % euclidean distance
            if r > sc.windowMinEcc && r < sc.windowMaxEcc
              
              sc.timeChoiceMade = sc.iFrame;

              sc.setState(5);
            end


        end
        
        
    end % methods
    
end % classdef