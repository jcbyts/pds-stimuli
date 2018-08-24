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
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(0); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).fixation.hFix.frameDraw(p);
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
              
            % get the state controller ready
            sc = s.sc;
            
            % iterate frame counter (counts when to show fixation point and when to show faces)
            s.frameCnt = mod(s.frameCnt+1,p.trial.(sn).fixation.flashCnt);

            % --- flash fixation until it is obtained
            if s.frameCnt == 0
                s.showFix = ~s.showFix; % flash fixation
            end
            
            if s.showFix % fixation on
                p.trial.(sn).fixation.hFix.stimValue  = true;
            else
                p.trial.(sn).fixation.hFix.stimValue  = false;
            end
            
            
            % --- Never obtained fixation
            if p.trial.ttime > p.trial.(sn).timing.trialTimeout
                % failed to initiate the trial... move to state 7 - breakfix imeout interval
                p.trial.(sn).fixation.hFix.stimValue = false; % make sure fixation point is on                p.trial.(sn).hFace.stimValue = false; % make sure face is off
                sc.setState(7);
                return
            end
            
            p.trial.(sn).fixation.hFix.frameUpdate(p);
            
            % --- check if fixating
            if p.trial.(sn).fixation.hFix.isFixated
                
                p.trial.(sn).frameFixationObtained   = p.trial.iFrame;
                p.trial.(sn).fixation.hFix.stimValue = true; % make sure fixation point is on
                
                % move to state 1 - fixation grace period
                sc.setState(1);
                return
            end
            
        end % after frame
        
    end % methods
    
end % classdef