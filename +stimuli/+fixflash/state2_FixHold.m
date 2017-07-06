classdef state2_FixHold < stimuli.state
    % state 2 - hold fixation for reward
    
    % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
    
    properties
        tStart = NaN;
        eyeXY
    end
    
    methods (Access = public)
        function s = state2_FixHold(hTrial,varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(2,hTrial); % call the parent constructor
        end
        
        % --- Drawing
        function beforeFrame(s)
            
            hTrial = s.hTrial;
            
            if hTrial.showFix
                hTrial.hFix(1).beforeFrame(); % draw fixation target
            end
        end
        
        % --- Update behavior
        function afterFrame(s,t)
            
            hTrial = s.hTrial;
            
            % --- Save time state began
            if isnan(s.tStart) % <-- first frame
                s.tStart = t;
                s.eyeXY = [hTrial.x,hTrial.y];
                hTrial.setTxTime(t); % save transition time
            end
            
            % --- If held to maximum duration --> move to next state
            if t > (s.tStart + hTrial.fixDuration)
                
                hTrial.holdXY       = mean(s.eyeXY);
                hTrial.holdDuration = t - s.tStart;
                
                % move to state 8 - inter-trial interval
                hTrial.setState(8);
                return;
            end
            
            % --- Check status of fixation
            r = norm([hTrial.x,hTrial.y]);
            
            if (r > hTrial.fixWinRadius) % left fixation window
                hTrial.holdDuration = t - s.tStart;

                hTrial.holdXY       = mean(s.eyeXY,1);
                
                hTrial.error = 2;
                hTrial.setState(7)

                return;
            end
            
            % keep track of fixated position
            s.eyeXY = [s.eyeXY; [hTrial.x hTrial.y]];
        end
        
    end % methods
    
end % classdef