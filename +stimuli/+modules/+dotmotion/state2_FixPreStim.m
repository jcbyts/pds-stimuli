classdef state2_FixPreStim < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
    end
    
    methods (Access = public)
        function s = state2_FixPreStim(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(2); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(s)
            
            % call draw functions for objects that should be shown
            s.sc.hFix.frameDraw();
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s)
            
            % get the state controller ready
            sc = s.sc;
            
            sc.hFix.frameUpdate(sc.eyeXY);

            % detect break fixations
            if ~sc.hFix.isFixated
                sc.setState(7);
                return
            end
            
            % check if time to show the targets
            if sc.iFrame >= (sc.timeFixationObtained + sc.timeTargOnset)
                sc.hTargs.stimValue = 1; % targets on
            end            
            
            % time to move to next state?
            if sc.iFrame >= (sc.timeFixationObtained + sc.timeMotionOnset)
                
%                 if p.trial.(sn).fixation.rewardForFixation
%                     warning('need to make this an object')
%                 end
                
                % turn on the motion stimulus
                sc.hMot.stimValue = true;
                sc.timeMotionTurnedOn = sc.iFrame;
                                
                % transition states
                sc.setState(3);
                return
            end
        end
        
        
    end % methods
    
end % classdef