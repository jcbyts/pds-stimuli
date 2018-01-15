classdef state2_Choice < stimuli.objects.state
    % state 2 - choose targets
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state2_Choice(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(2); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            for k = 1:numel(p.trial.(sn).hDots)
                p.trial.(sn).hDots(k).frameDraw(p);
            end
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % --- Time to transition to next state if fixation is held
            startTime = sc.getTxTime(s.id) - p.trial.trstart;
            
            % check if the time has expired
            if p.trial.ttime > (p.trial.(sn).choiceGracePeriod + startTime)
                sc.setState(7); % break fixation
                return
            end
            
            % check if a target is fixated
            for k = 1:numel(p.trial.(sn).hDots)
                p.trial.(sn).hDots(k).frameUpdate(p);
                p.trial.(sn).hDots(k).isHeld([p.trial.eyeX p.trial.eyeY]);
                
                if p.trial.(sn).hDots(k).isFixated
                    p.trial.(sn).dotsChosen = k;
                    sc.setState(3);
                    return
                end
            end
      
        end
        
        
    end % methods
    
end % classdef