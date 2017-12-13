classdef state2_FixHold < stimuli.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY
    end
    
    methods (Access = public)
        function s = state2_FixHold(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(2); % call the parent constructor
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
            
            % --- Save start of state
            if isnan(s.tStart) % <-- first frame
                s.tStart = sc.getTxTime(s.id);
            end
            
            % --- If held to maximum duration --> move to next state
            if p.trial.ttime > (s.tStart + p.trial.(sn).fixDuration)
                
                p.trial.(sn).holdXY       = mean(s.eyeXY);
                p.trial.(sn).holdDuration = p.trial.ttime - s.tStart;
                
                % move to state 8 - inter-trial interval
                sc.setState(8);
                return
            end
            
            % --- Check status of fixation
            if ~p.trial.(sn).hFix.isFixated % left fixation window
            
                p.trial.(sn).holdDuration = p.trial.ttime - s.tStart;

                p.trial.(sn).holdXY       = mean(s.eyeXY,1);
                
                sc.setState(7) % break fixation state

                return
            end
            
            % keep track of fixated position
            s.eyeXY = [s.eyeXY; [p.trial.eyeX p.trial.eyeY]];
        end
        
    end % methods
    
end % classdef