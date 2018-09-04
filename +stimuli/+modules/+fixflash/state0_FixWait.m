classdef state0_FixWait < stimuli.objects.state
    % state 0 - wait for fixation
    
    % --- Parameters that make this state operate
    properties (Access = public)
        
        % properties for flashing the fixation target
        showFix=false;
        frameCnt  = 0; % frame counter (for this state?)
        faceFlash = 0; % face intermixed in flashing point
    end
    
    methods (Access = public)
        
        function s = state0_FixWait(varargin) % constructor
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(0); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).hFix.frameDraw();
            % draw face on top of fixation point?
            p.trial.(sn).hFace.frameDraw();
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
              
            % get the state controller ready
            sc = s.sc;
            
            % iterate frame counter
            s.frameCnt = mod(s.frameCnt+1,p.trial.(sn).fixFlashCnt);
            
            % --- flash fixation until it is obtained
            if s.frameCnt == 0
                
                s.showFix = ~s.showFix; % flash fixation
                
                if s.showFix
                    s.faceFlash = s.faceFlash + 1; % count flashes
                end
            end
            
            if s.showFix % fixation on
                
                % --- show face every 3rd flash
                if mod(s.faceFlash, 3)==0 % is face?
                    p.trial.(sn).hFace.stimValue = true;
                    p.trial.(sn).hFix.stimValue  = false;
                else % not face
                    p.trial.(sn).hFace.stimValue = false;
                    p.trial.(sn).hFix.stimValue  = true;
                end
            else
                p.trial.(sn).hFace.stimValue = false;
                p.trial.(sn).hFix.stimValue  = false;
            end
            
            
            % --- Never obtained fixation
            if p.trial.ttime > p.trial.(sn).trialTimeout
                % failed to initiate the trial... move to state 7 - timeout interval
                p.trial.(sn).hFix.stimValue = false; % make sure fixation point is on
                p.trial.(sn).hFace.stimValue = false; % make sure face is off
                sc.setState(7);
                return
            end
            
            % --- check if fixating
            if p.trial.(sn).hFix.isFixated
                
                p.trial.(sn).hFix.stimValue = true; % make sure fixation point is on
                p.trial.(sn).hFace.stimValue = false; % make sure face is off
                
                % move to state 1 - fixation grace period
                sc.setState(1);
                return
            end
            
        end % after frame
        
    end % methods
    
end % classdef