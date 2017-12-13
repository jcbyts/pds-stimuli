classdef stimulus < handle %#ok<*MCSUP>
    % STIMULUS is a handle class that logs how its property changes
    %   The property STIMVALUE will be inherited by any stimulus and any time
    %   it is changed, the time of change will be logged and saved in the
    %   property LOG
    
    properties (Access = public)
        stimValue
    end
    
    properties (SetAccess = ?stimuli.stimulus, GetAccess = public)
        log
    end
    
    methods
        % --- class constructor
        function obj = stimulus(varargin)
            obj.stimValue = true; % the stimulus defaults to a value of true
        end
        
        % --- set function logs the value when it is change
        function set.stimValue(obj, val)
            obj.stimValue = val;
            obj.log(:,end+1) = [obj.stimValue; GetSecs];
        end
    end
    
end