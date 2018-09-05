classdef state0_FixWait < stimuli.objects.state
    % state 0 - wait for fixation
    
    % --- Parameters that make this state operate
    properties (Access = public)
        
        % properties for flashing the fixation target
        showFix=false;
        frameCnt  = 0; % frame counter (for this state?)
    end
    
    methods (Access = public)
        
        function s = state0_FixWait(varargin) % constructor
%             fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(0); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(s)
            
            % call draw functions for objects that should be shown
%             p.trial.(sn).fixation.hFix.frameDraw(p);
            s.sc.hFix.frameDraw();
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s)
              
            % get the state controller ready
            sc = s.sc;
            iFrame = sc.iFrame;
            
            % iterate frame counter (counts when to show fixation point and when to show faces)
            s.frameCnt = mod(s.frameCnt+1,sc.fixFlashCnt);

            % --- flash fixation until it is obtained
            if s.frameCnt == 0
                s.showFix = ~s.showFix; % flash fixation
            end
            
            if s.showFix % fixation on
                sc.hFix.stimValue  = true;
            else
                sc.hFix.stimValue  = false;
            end
            
            
            % --- Never obtained fixation
            if iFrame > sc.timeTrialTimeout
                % failed to initiate the trial... move to state 7 - breakfix imeout interval
                sc.hFix.stimValue = false; % make sure fixation point is on                p.trial.(sn).hFace.stimValue = false; % make sure face is off
                sc.setState(7);
                return
            end
            
            sc.hFix.frameUpdate(sc.eyeXY);
            
            % --- check if fixating
            if sc.hFix.isFixated
                
                sc.timeFixationObtained   = iFrame;
                sc.hFix.stimValue = true; % make sure fixation point is on
                
                % move to state 1 - fixation grace period
                sc.setState(1);
                return
            end
            
        end % after frame
        
    end % methods
    
end % classdef