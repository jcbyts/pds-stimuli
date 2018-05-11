classdef state3_showStim < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state3_showStim(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(3); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            % show fixation point
            p.trial.(sn).hFix.frameDraw(p);
            
            % show stimulus                
            for k = 1:numel(p.trial.(sn).hTargs)
                p.trial.(sn).hTargs(k).frameDraw(p);
            end
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            for k = 1:numel(p.trial.(sn).hTargs)
                p.trial.(sn).hTargs(k).frameUpdate(p);
            end
            
            if ~p.trial.(sn).hFix.isFixated
                sc.setState(7); % break fixation
            end
            
            startTime = sc.getTxTime(s.id) - p.trial.trstart;
            
            if (p.trial.ttime - startTime) >= p.trial.(sn).fixDurPostStim
                p.trial.(sn).hFix.stimValue = 0; % turn off fixation. TODO: dim?
                sc.setState(4);
                return
            end
      
        end
        
        
    end % methods
    
end % classdef