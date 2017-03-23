classdef state0_FixWait < stimuli.state
    % state 0 - wait for fixation
    
    % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
    % 05-01-2017 - Jake L. Yates <jacoby8s@gmail.com>
    
    properties
        tStart = NaN;
        
        % properties for flashing the fixation target
        showFix@logical = true;
        frameCnt  = 0; % frame counter (for this state?)
        faceFlash = 0; % face intermixed in flashing point
        showFace  = 0; % show face instead of point
    end
    
    methods (Access = public)
        function s = state0_FixWait(hTrial,varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(0,hTrial); % call the parent constructor
        end
        
        % --- Drawing commands
        function beforeFrame(s)
            
            hTrial = s.hTrial;
            
            if hTrial.showFix && s.showFix
                if s.showFace
                    hTrial.hFace.beforeFrame();
                else
                    hTrial.hFix(1).beforeFrame(); % draw fixation target
                end
            end
        end % before frame
        
        % -- Evaluate states (prepare before drawing)
        function afterFrame(s,t)
            
            hTrial = s.hTrial;
            
            % --- Save start of state
            if isnan(s.tStart) % <-- first frame
                s.tStart = t;
                hTrial.setTxTime(t); % save transition time
            end
            
            % iterate frame counter
            s.frameCnt = mod(s.frameCnt+1,hTrial.fixFlashCnt);
            
            % --- flash fixation until it is obtained
            if s.frameCnt == 0
                s.showFix  = ~s.showFix; % toggle fixation target (makes flash)
                
                if s.showFix
                    s.faceFlash = s.faceFlash + 1; % count flashes
                end
                
            end
            
            % --- show face every 3rd flash
            if mod(s.faceFlash, 3)==0
                s.showFace = s.showFix;
            end
            
            % --- Never obtained fixation
            if t > (s.tStart + hTrial.trialTimeout)
                % failed to initiate the trial... move to state 7 - timeout interval
                hTrial.error = 1;
                hTrial.setState(7);
                return
            end
            
            % --- check if fixating
            r = norm([hTrial.x,hTrial.y]);
            
            if (r < hTrial.fixWinRadius)
                % move to state 1 - fixation grace period
                hTrial.setState(1);
                return
            end
            
        end % after frame
        
    end % methods
    
end % classdef