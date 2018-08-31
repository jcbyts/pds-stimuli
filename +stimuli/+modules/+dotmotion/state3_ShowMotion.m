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
            
            % update motion
            sc.hMot.frameUpdate();
            sc.hFix.frameUpdate(sc.eyeXY);
            
            % detect break fixations (fixation must be held during this state)
            if ~sc.hFix.isFixated
                sc.setState(7);
                return
            end
            
            % check if time to show the targets
            if sc.iFrame >= (sc.timeFixationObtained + sc.timeTargOnset)
                sc.hTargs.stimValue = 1; % targets on
            end
            
            % time to turn off motion
            if sc.iFrame >= (sc.timeMotionTurnedOn + sc.timeMotionOffset)
                sc.hMot.stimValue = 0;
                sc.timeMotionTurnedOff = sc.iFrame;
            end
            
            % time to turn on cue
            if sc.iFrame >= (sc.timeMotionTurnedOn + sc.timeCueOnset)
                sc.hCue.stimValue = 1;
                sc.timeCueTurnedOn = sc.iFrame;
            end
            
            % time to turn off fixation
            if sc.iFrame >= (sc.timeFixationObtained + sc.timeFixationOffset)
                sc.hFix.stimValue = 0;
                sc.timeFixationTurnedOff = sc.iFrame;
            end
            
            % this state ends when the period of required fixation is over
            if sc.iFrame >= (sc.timeFixationObtained + sc.timeStopFixationHold)
%                 sc.hFix.color = p.trial.display.clut.fixSurColorDim;
%                 sc.hFix.ctrColor = p.trial.display.clut.fixCtrColorDim;
%                 sc.hFix.wincolor = []; % window off, no fixation requirement
                sc.timeFixDim = sc.iFrame;
                
                % transition states
                sc.setState(4); % transition to wait for choice
                return
            end
            
            
        end
        
        
    end % methods
    
end % classdef