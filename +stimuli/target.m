classdef target < stimuli.stimulus %#ok<*MCSUP>
% TARGET is a STIMULUS that has a position and can be fixated
% use this class if the stimulus behavior depends on whether the animal is
% looking at it

    properties
        xyPix     = [0 0] % location on screen (in pixels)
        winRadius = 20    % radius for detecting fixation
    end
    
    properties (SetAccess = private, GetAccess = public) % you cannot write to these
        isFixated
        fixlog
    end
    
    methods
        % class constructor
        function obj = target(varargin)
            
            obj = obj@stimuli.stimulus();
            if nargin > 0
                obj.xyPix = varargin{1};
            end
            
            obj.isFixated = false; % initialize to non-fixated state
        end
        
        function set.isFixated(obj, val)
            obj.isFixated = val;
            obj.fixlog(:, end+1) = [val; GetSecs];
        end
        
        function out = isHeld(obj, xyEye)
            % ISHELD checks if the the target is being fixated
            % val = isHeld(target, xyEye)
            %   xyEye [1 x 2] x,y position of the eye (in pixels)
            
            % check if fixated
            val = norm(xyEye(:) - obj.xyPix(:)) < obj.winRadius;
               
            % log changes
            if val ~= obj.isFixated
                obj.isFixated = val;
            end
            
            if nargout > 0
                out = val;
            end
            
        end
        
    end
    
    
end