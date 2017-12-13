classdef state0_FixWait < stimuli.state
    % state 0 - wait for fixation
    
    % --- Parameters that make this state operate
    properties (Access = public)
        
        % properties for flashing the fixation target
        frameCnt  = 0; % frame counter (for this state?)
        faceFlash = 0; % face intermixed in flashing point
    end
    
    methods (Access = public)
        
        function s = state0_FixWait(varargin) % constructor
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.state(0); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).hFix.frameDraw(p);
            % draw face on top of fixation point?
            p.trial.(sn).hFace.frameDraw(p);
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % --- Save start of state
            if isnan(s.tStart) % <-- first frame
                s.tStart = sc.getTxTime(s.id);
            end
            
            % iterate frame counter
            s.frameCnt = mod(s.frameCnt+1,p.trial.(sn).fixFlashCnt);
            
            % --- flash fixation until it is obtained
            if s.frameCnt == 0
                
                % --- show face every 3rd flash
                if mod(s.faceFlash, 3)==0
                    p.trial.(sn).hFace.stimValue = true;
                else
                    p.trial.(sn).hFace.stimValue = false;
                    % flip state of the fixation point
                    p.trial.(sn).hFix.stimValue = ~p.trial.(sn).hFix.stimValue;
                end
                
                if p.trial.(sn).hFix.stimValue
                    s.faceFlash = s.faceFlash + 1; % count flashes
                end
                
            end
            
            
            % --- Never obtained fixation
            if p.trial.ttime > (s.tStart + p.trial.(sn).trialTimeout)
                % failed to initiate the trial... move to state 7 - timeout interval
                sc.setState(7);
                return
            end
            
            % --- check if fixating
            if p.trial.(sn).hFix.isFixated
                % move to state 1 - fixation grace period
                hTrial.setState(1);
                return
            end
            
        end % after frame
        
    end % methods
    
end % classdef