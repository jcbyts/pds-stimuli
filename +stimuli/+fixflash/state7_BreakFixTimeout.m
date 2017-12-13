classdef state7_BreakFixTimeout < stimuli.state
  % state 7 - break fixation timeout interval
 
  % TODO: maybe just use sc.getTxTime instead of s.tStart??
  properties
  end
  
  methods (Access = public)
    function s = state7_BreakFixTimeout(varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(7); % call the parent constructor
    end
    
    function frameDraw(~,~,~)
        % break fix do nothing
    end
    
    function frameUpdate(s, p, sn)
        
        % get the state controller ready
        sc = s.sc;
        
        % --- Save start of state
        if isnan(s.tStart) % <-- first frame
            s.tStart = sc.getTxTime(s.id);
        end
        
        if (p.trial.ttime > (s.tStart + p.trial.(sn).iti))
            p.trial.flagNextTrial = true;
            return
        end
        
    end % after frame
    
  end % methods
  
end % classdef