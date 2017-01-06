classdef dotMotionState7 < stimuli.state
  % state 7 - timeout interval
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN; % 'start' time
        
    plotFlag = false; % urgh! true after we've updated the gui
  end
  
  methods (Access = public)
    function s = dotMotionState7(hTrial,varargin),
      fprintf(1,'dotMotionState7()\n');
      
      s = s@stimuli.state(7,hTrial); % call the parent constructor
    end
    
    function beforeFrame(s),
%       fprintf(1,'dotMotionState7.beforeFrame()\n');
      
      hTrial = s.hTrial;
    end
    
    function afterFrame(s,t),
%       fprintf(1,'dotMotionState7.afterFrame()\n');
 
      hTrial = s.hTrial;
      
      if isnan(s.tStart), % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
      end
      
      if (t > (s.tStart + hTrial.iti)),
        % done...
        hTrial.done = true;
        return;
      end
      
      % FIXME: Urgh!
      if ~s.plotFlag,
%         eval(hTrial.A.plotCmd);
        s.plotFlag = true;
        
        if hTrial.viewpoint,
          vpx_SendCommandString(sprintf('dataFile_InsertString "TRIALEND:TRIALNO:%i"',hTrial.trialNum));
        end
      end
    end
    
  end % methods
  
end % classdef