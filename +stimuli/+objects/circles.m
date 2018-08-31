classdef circles  < stimuli.objects.stimulus
    % CIRCLES draws circles

  properties
    radius
    position
    weight
    color
  end


  methods
      function o = circles(winPtr, varargin)
          
          o = o@stimuli.objects.stimulus(winPtr, varargin{:});
          
          ip = inputParser();
          ip.addOptional('radius', 300)
          ip.addOptional('position', [960 540])
          ip.addOptional('weight', 10)
          ip.addOptional('color', [1 1 1])
          ip.parse(varargin{:})
          
          o.radius   = ip.Results.radius;
          o.position = ip.Results.position;
          
      end

    function frameUpdate(~)
        % do nothing
    end

    function frameDraw(o)
      if o.stimValue
        r = o.radius; % radius in pixels
      
        rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
        if o.weight > 0,
            Screen('FrameOval', o.ptr, o.color, rect', o.weight);
        else
            Screen('FillOval', o.ptr, o.color, rect');
        end
        
      end
      
      if 0, % for debugging...
        th = [0:0.05:1]*2*pi;
%         r = ones(size(th))*r; % pixels
        [r,th] = meshgrid(r,th);      

        for ii = 1:size(r,2),
          [x,y] = pol2cart(th(:,ii),r(:,ii));
      
          hold on;
          plot(x+o.position(1),y+o.position(2),'-','Color',o.color);
%           axis([-1, 1, -1, 1]*20);
%           axis equal;
          hold off
        end
      end % if 0|1
      

    end

  end

end