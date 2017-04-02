classdef state1_Fixed < stimuli.state
    % state 0 - wait for fixation
    
    % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
    % 05-01-2017 - Jake L. Yates <jacoby8s@gmail.com>
    
    properties
        tStart = NaN;
        
        % properties for flashing the fixation target
        showFix@logical = true;
        frameCnt  = 0; % frame counter (for this state?)
    end
    
    methods (Access = public)
        function s = state1_Fixed(hTrial,varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(0,hTrial); % call the parent constructor
        end
        
        % --- Drawing commands
        function beforeFrame(s)
            
            hTrial = s.hTrial;
            
            % draw gratings
            hTrial.hGratings.beforeFrame();
            
        end % before frame
        
        % -- Evaluate states (prepare before drawing)
        function afterFrame(s,t)
            
            hTrial = s.hTrial;
            
            % --- Save start of state
            if isnan(s.tStart) % <-- first frame
                s.tStart = t;
                hTrial.setTxTime(t); % save transition time
            end
                       

            % --- End trial
            if t > (s.tStart + hTrial.trialTimeout)
                hTrial.error = 0;
                hTrial.setState(8);
                return
            end
            
            % --- check if fixating
            r = sqrt((hTrial.x - hTrial.hGratings.position(:,1)).^2 + (hTrial.y - hTrial.hGratings.position(:,2)).^2);
            
            if any(r < hTrial.fixWinRadius)
                % move to state 1 - fixation grace period
                hTrial.setState(1);
                return
            end
            
        end % after frame
        
    end % methods
    
end % classdef