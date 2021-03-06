classdef state7_BreakFixTimeout < stimuli.objects.state
  % state 7 - break fixation timeout interval
 
  % TODO: maybe just use sc.getTxTime instead of s.tStart??
  properties
  end
  
  methods (Access = public)
    function s = state7_BreakFixTimeout(varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.objects.state(7); % call the parent constructor
    end
    
    function frameDraw(~,p,~)
        % draw big red screen for bad!
        Screen('FillRect', p.trial.display.ptr, [1 0 0])
    end
    
    function frameUpdate(s, p, sn)
        
        % get the state controller ready
        sc = s.sc;
        
            
        % --- Save start of state
%         tStart = sc.getTxTime(s.id) - p.trial.trstart;
        
        if (p.trial.ttime > p.trial.(sn).timing.iti)
%             p.trial.flagNextTrial = true;
            sc.setState(8)
            return
        end
        
    end % after frame
    
  end % methods
  
end % classdef