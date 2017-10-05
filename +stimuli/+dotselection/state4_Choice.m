classdef state4_Choice < stimuli.state
  % state 5 - choice
  
  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties
    tStart = NaN;
  end
  
  methods (Access = public)
    function s = state4_Choice(hTrial,varargin)
      fprintf(1,'%s\n',mfilename);
      
      s = s@stimuli.state(4,hTrial); % call the parent constructor
    end
    
    function beforeFrame(s)
        %       fprintf(1,'dotMotionState5.beforeFrame()\n');
        
        hTrial = s.hTrial;
        
        if hTrial.showDots
            for k = 1:2
                hTrial.hDots(k).beforeFrame();
            end
        end
    end
    
    function afterFrame(s,t)
%       fprintf(1,'dotMotionState5.afterFrame()\n');
      
      hTrial = s.hTrial;
      
      if isnan(s.tStart) % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
      end
      

      %compute distance from center of the dotfield, store in r
      if hTrial.showDots
          for k = 1:2
              hTrial.hDots(k).afterFrame();
              r(k) = norm([hTrial.x*hTrial.ppd + hTrial.ctr(1) - hTrial.hDots(k).position(1),-hTrial.y*hTrial.ppd + hTrial.ctr(2) - hTrial.hDots(k).position(2)]);
          end
      end
      
      % r
      
      for k = 1:2
          if r(k) < hTrial.hDots(k).maxRadius
              hTrial.choice = k;
              hTrial.setState(5);
              return
          end
      end
     
      if t > (s.tStart + hTrial.choiceTimeout)
        % timed out... move to state 8 - inter-trial interval
        hTrial.error = 4;
        hTrial.setState(8);
        return;
      end
       
      
      
      
    end
    
  end % methods
  
end % classdef
