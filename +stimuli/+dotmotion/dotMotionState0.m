classdef dotMotionState0 < stimuli.state
  % state 0 - wait for fixation

  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  % 01-05-2017 - Jake L. Yates <jacoby8s@gmail.com>

  properties
    tStart = NaN;
    
    % properties for flashing the fixation target
    showFix@logical = true;
    frameCnt = 0; % frame counter
  end
  
  methods (Access = public)
    function s = dotMotionState0(hTrial,varargin),
      fprintf(1,'dotMotionState0()\n');
      
      s = s@stimuli.state(0,hTrial); % call the parent constructor      
    end
    
    function framePrepareDrawing(s)
       hTrial = s.hTrial;
      
      if isnan(s.tStart), % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
                
        if hTrial.viewpoint,
          % FIXME: send trial marker to ViewPoint...
          %
          % this could be handles much more elegantly using a TRIALSTART
          % event and just .notify()'ing all the listeners of TRIALSTART
          vpx_SendCommandString(sprintf('dataFile_InsertString "TRIALSTART:TRIALNO:%i"',hTrial.trialNum));
        end
      end
      
      s.frameCnt = mod(s.frameCnt+1,hTrial.fixFlashCnt);
      if s.frameCnt == 0,
        s.showFix = ~s.showFix; % toggle fixation target
      end
      
      if t > (s.tStart + hTrial.trialTimeout),
        % failed to initiate the trial... move to state 7 - timeout interval
        hTrial.error = 1;
        hTrial.setState(7);
        return
      end
      
      r = norm([hTrial.x,hTrial.y]);
      
      if (r < hTrial.fixWinRadius),
        % move to state 1 - fixation grace period
        hTrial.setState(1);
        return
      end

    end
    
    function frameDraw(s)
      hTrial = s.hTrial;

      if hTrial.showFix && s.showFix,
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      end

    end
    
    function beforeFrame(s),
%       fprintf(1,'dotMotionState0.beforeFrame()\n');
      
      hTrial = s.hTrial;

      if hTrial.showFix && s.showFix,
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      end
    end
    
    function afterFrame(s,t),
%       fprintf(1,'dotMotionState0.afterFrame()\n');
            
      hTrial = s.hTrial;
      
      if isnan(s.tStart), % <-- first frame
        s.tStart = t;
        hTrial.setTxTime(t);
                
        if hTrial.viewpoint,
          % FIXME: send trial marker to ViewPoint...
          %
          % this could be handles much more elegantly using a TRIALSTART
          % event and just .notify()'ing all the listeners of TRIALSTART
          vpx_SendCommandString(sprintf('dataFile_InsertString "TRIALSTART:TRIALNO:%i"',hTrial.trialNum));
        end
      end
      
      s.frameCnt = mod(s.frameCnt+1,hTrial.fixFlashCnt);
      if s.frameCnt == 0,
        s.showFix = ~s.showFix; % toggle fixation target
      end
      
      if t > (s.tStart + hTrial.trialTimeout),
        % failed to initiate the trial... move to state 7 - timeout interval
        hTrial.error = 1;
        hTrial.setState(7);
        return
      end
      
      r = norm([hTrial.x,hTrial.y]);
      
      if (r < hTrial.fixWinRadius),
        % move to state 1 - fixation grace period
        hTrial.setState(1);
        return
      end
    end
    
  end % methods
  
end % classdef