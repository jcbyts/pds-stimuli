classdef state1_FixGracePeriod < stimuli.objects.state
    % state 1 - fixation grace period
    % Time alotted after entering fixation window before Hold Fixation begins
    
    
    methods (Access = public)
        function s = state1_FixGracePeriod(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(1); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(s)
            
            % call draw functions for objects that should be shown
            s.sc.hFix.frameDraw();
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s)
              
            % get the state controller ready
            sc = s.sc;
            
            % calculate the timegracePeriod time to transition if fixation
            % hold is maintained
            transitionTime = sc.timeFixationObtained + sc.timeFixGracePeriod;
            
            % if during grace period, do nothing
            if sc.iFrame < transitionTime
                return;
            end
            
            sc.hFix.frameUpdate(sc.eyeXY);
            
            if ~sc.hFix.isFixated
                % broke fixation... move to state 7 - timeout
                sc.setState(7);   % break fixation timeout
                return;
            end
            
            sc.setState(2); % ---> to show stim
            
        end % after frame
        
    end % methods
    
end % classdef