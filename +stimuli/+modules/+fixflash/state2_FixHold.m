classdef state2_FixHold < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state2_FixHold(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(2); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).hFix.frameDraw(p);
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % --- Time to transition to next state if fixation is held
            startTime = sc.getTxTime(s.id) - p.trial.trstart;
            
            
            % --- If held to maximum duration --> move to next state
            if p.trial.ttime > startTime + p.trial.(sn).fixDuration + p.trial.(sn).fixStartOffset
                
                p.trial.(sn).holdXY       = nanmean(s.eyeXY, 1); % record eye position
                p.trial.(sn).holdDuration = p.trial.ttime - startTime;
                
                % move to state 8 - inter-trial interval
                sc.setState(8);
                return
            end
            
            % --- Check status of fixation
            if ~p.trial.(sn).hFix.isFixated % left fixation window
            
                p.trial.(sn).holdDuration = p.trial.ttime - startTime;

                p.trial.(sn).holdXY       = nanmean(s.eyeXY,1);
                
                sc.setState(7) % break fixation state

                return
            end
            
            % keep track of fixated position
            s.eyeXY = [s.eyeXY; [p.trial.eyeX p.trial.eyeY]];
        end
        
    end % methods
    
end % classdef