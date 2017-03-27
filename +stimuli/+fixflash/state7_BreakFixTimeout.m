classdef state7_BreakFixTimeout < stimuli.state
  % state 7 - timeout interval
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN; % 'start' time        
  end
  
  methods (Access = public)
    function s = state7_BreakFixTimeout(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(7,hTrial); % call the parent constructor
    end
    
    function beforeFrame(s)
%       fprintf(1,'dotMotionState7.beforeFrame()\n');
      
%       hTrial = s.hTrial;
    end
    
    function afterFrame(s,t)
%       fprintf(1,'dotMotionState7.afterFrame()\n');
 
      hTrial = s.hTrial;
      
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
      end
      
      if (t > (s.tStart + hTrial.iti))
        % done...
        hTrial.done = true;
        return;
      end
      
    end % after frame
    
  end % methods
  
end % classdef