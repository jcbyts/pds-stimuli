classdef state8_ITI < stimuli.state
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
        function s = state8_ITI(hTrial,varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(8,hTrial); % call the parent constructor
        end
        
        % --- Drawing commands
        function beforeFrame(s)
            
            % do nothing
            
        end % before frame
        
        % -- Evaluate states (prepare before drawing)
        function afterFrame(s,t)
            
            hTrial = s.hTrial;
            
            % --- Save start of state
            if isnan(s.tStart) % <-- first frame
                s.tStart = t;
                hTrial.setTxTime(t); % save transition time
            end
                   
            if (t > (s.tStart + hTrial.iti))
                % done...
                hTrial.done = true;
                return;
            end
            
        end % after frame
        
    end % methods
    
end % classdef