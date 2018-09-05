classdef state1_showStim < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state1_showStim(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(1); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            for k = 1:numel(p.trial.(sn).hTargs)
                p.trial.(sn).hTargs(k).frameDraw();
            end
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % fieldname for the fixation behavior
            fixSn  = p.trial.(sn).fixationBehavior;
            
            for k = 1:numel(p.trial.(sn).hTargs)
                p.trial.(sn).hTargs(k).frameUpdate(p);
            end
            
            if ~p.trial.(fixSn).hFix.isFixated
                sc.setState(7); % break fixation
            end
            
            if p.trial.(fixSn).states.currentState.id > 2 % fixHold has finished
                
                sc.setState(2);
                return
            end
      
        end
        
        
    end % methods
    
end % classdef