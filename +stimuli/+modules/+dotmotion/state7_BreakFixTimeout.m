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
    
    function frameDraw(s)
        % draw big red screen for bad!
%         Screen('FillRect', p.trial.display.ptr, [1 0 0])
    end
    
    function frameUpdate(s)
        
        % get the state controller ready
        sc = s.sc;
        
            
        % --- Save start of state
%         tStart = sc.getTxTime(s.id) - p.trial.trstart;
        
        if sc.iFrame > sc.timeITI
            sc.setState(8)
            return
        end
        
    end % after frame
    
  end % methods
  
end % classdef