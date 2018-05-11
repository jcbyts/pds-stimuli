classdef state1_FixGracePeriod < stimuli.objects.state
    % state 1 - fixation grace period
    % Time alotted after entering fixation window before Hold Fixation begins
    
    
    methods (Access = public)
        function s = state1_FixGracePeriod(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(1); % call the parent constructor
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
            
            % calculate the timegracePeriod time to transition if fixation
            % hold is maintained
            transitionTime = (sc.getTxTime(s.id) + p.trial.(sn).fixGracePeriod - p.trial.trstart);
            
            % if during grace period, do nothing
            if p.trial.ttime < transitionTime
                return;
            end
            
            if ~p.trial.(sn).hFix.isFixated
                % broke fixation... move to state 7 - timeout
                sc.setState(7);   % break fixation timeout
                return;
            end
            
            %if p.trial.(sn).rewardForObtainFixation
                % move to state 2 - hold fixation
            %    pds.behavior.reward.give(p);
            %end
            
            sc.setState(2); % ---> to show stim
            
        end % after frame
        
    end % methods
    
end % classdef