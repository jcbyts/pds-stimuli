classdef state1_FixGracePeriod < stimuli.state
    % state 1 - fixation grace period
    % Time alotted after entering fixation window before Hold Fixation begins
    
    % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
    
    properties
        tStart = NaN;
    end
    
    methods (Access = public)
        function s = state1_FixGracePeriod(hTrial,varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(1,hTrial); % call the parent constructor
        end
        
        % --- Drawing
        function beforeFrame(s)
            
            hTrial = s.hTrial;
            
            % --- if fixation point is supposed to be on. Draw it
            if hTrial.showFix
                hTrial.hFix(1).beforeFrame(); % draw fixation target
            end
        end % before frame
        
        % --- Update behavior of states
        function afterFrame(s,t)
            
            hTrial = s.hTrial;
            
            if isnan(s.tStart) % <-- first frame
                s.tStart = t;
                hTrial.setTxTime(t); % save transition time
            end
            
            % if during grace period, do nothing
            if t < (s.tStart + hTrial.fixGracePeriod)
                return;
            end
            
            % check if fixating
            r = norm(hTrial.x,hTrial.y);
            
            if r > hTrial.fixWinRadius
                % broke fixation... move to state 7 - timeout
                hTrial.error = 2;     % break fixation
                hTrial.setState(7);   % break fixation timeout
                return;
            end
            
            if hTrial.rewardForObtainFixation
                % move to state 2 - hold fixation
                hTrial.hReward.give();
            end
            
            hTrial.setState(2); % ---> to fix hold
        end % after frame
        
    end % methods
    
end % classdef