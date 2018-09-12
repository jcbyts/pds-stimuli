% class for delivering auditory feedback

% 20-05-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>

classdef sound < marmoview.feedback
  properties (SetAccess = private, GetAccess = private)
    s@audioplayer;
  end 
  
  properties (Constant, Access = private)
    fs = 16e3;l % 16 kHz
  end
  
  methods
    function o = sound(h,varargin),
%       fprintf(1,'marmoview.sound()\n');

      o = o@marmoview.feedback(h,varargin{:}); % call parent constructor
            
      t = 0:1/o.fs:0.075; % 75 ms tone
      o.s = audioplayer(randn(size(t)).*exp(-((t-0.015)./0.002).^2),o.fs);
    end
    
    function deliver(o,varargin),
      o.s.play();
    end
    
    function r = report(o),
      r = [];
    end
  end % methods
  
end % classdef
