classdef stimulus < handle %#ok<*MCSUP>
    % STIMULUS is a handle class that logs how its property changes
    %   The property STIMVALUE will be inherited by any stimulus and any time
    %   it is changed, the time of change will be logged and saved in the
    %   property LOG
    
    properties (Access = public)
        stimValue
        rng@RandStream=RandStream('mt19937ar')
    end
    
    properties (SetAccess = ?stimuli.stimulus, GetAccess = public)
        log
    end
    
    methods
        % --- class constructor
        function obj = stimulus(varargin)
            obj.stimValue = true; % the stimulus defaults to a value of true
            
            rngArg  = find(cellfun(@(x) strcmp(x, 'rng'), varargin));
            seedArg = find(cellfun(@(x) strcmp(x, 'seed'), varargin));
            
            if ~isempty(rngArg)
                obj.rng = varargin{rngArg+1};
            end
            
            if ~isempty(seedArg)
                obj.rng = RandStream(obj.rng.Type, 'Seed', varargin{seedArg+1});
            end
            
        end
        
        % --- set function logs the value when it is change
        function set.stimValue(obj, val)
            if obj.stimValue==val
                return
            end
            obj.stimValue = val;
            obj.log(:,end+1) = [obj.stimValue; GetSecs];
        end
        
        function setRandomSeed(obj, arg)
            % can pass in a RandStream object
            % a seed
            % or nothing
            
            if nargin < 2
                seed = randi(10^7);
            else
                seed = arg;
            end
            
            if isa(seed, 'RandStream')
                obj.rng = seed;
            else
                obj.rng = RandStream(obj.rng.Type, 'Seed', seed);
            end
            
        end
    end
    
end