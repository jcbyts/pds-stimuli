classdef state8_InterTrialInterval < stimuli.objects.state
  % state 8 - inter trial interval
 
  % TODO: maybe just use sc.getTxTime instead of s.tStart??
  properties
  end
  
  methods (Access = public)
    function s = state8_InterTrialInterval(varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.objects.state(8); % call the parent constructor
    end
    
    function frameDraw(~,p,~)
        Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor)
        % do nothing
    end
    
    function frameUpdate(s, p, sn)
        
        % get the state controller ready
        sc = s.sc;
            
        % --- Save start of state
        tStart = sc.getTxTime(s.id) - p.trial.trstart;
        
        if (p.trial.ttime > (tStart + p.trial.(sn).timing.iti))
            p.trial.flagNextTrial = true;
            return
        end
        
    end % after frame
    
  end % methods
  
end % classdef