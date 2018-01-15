classdef state3_HoldChoice < stimuli.objects.state
    % state 2 - choose targets
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state3_HoldChoice(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(3); % call the parent constructor
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
            
            % check if dots are being held
            p.trial.(sn).hDots(p.trial.(sn).dotsChosen).isHeld([p.trial.eyeX p.trial.eyeY]);
            
            if ~p.trial.(sn).hDots(p.trial.(sn).dotsChosen).isFixated
                sc.setState(7); % break fixation
                return
            elseif p.trial.ttime > (startTime + p.trial.(sn).choiceHoldDuration)
                sc.setState(8); % reward ITI
                return
            end
            
      
        end
        
        
    end % methods
    
end % classdef