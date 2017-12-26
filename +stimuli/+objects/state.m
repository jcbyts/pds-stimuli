% abstract class for stimulus paradigm states

% 07-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.irg>
% (Abstract) 
classdef state < handle
    % Abstract class for a stimulus paradigm states.
    %
    % To see the public properties of this class, type
    %
    %   properties(stimuli.state)
    %
    % To see a list of methods, type
    %
    %   methods(stimuli.state)
    %
    % The class constructor can be called with a range of arguments:
    %
    %   None.
    
    % note: the @state class together with the @trial class implement the
    %       so called 'state' pattern... the @trial object provides the
    %       context while the @state class provides the state specific
    %       behaviour and transition logic

    properties (Access = {?stimuli.objects.stateControl,?stimuli.objects.state})
        id@double; % state identifier
        sc@stimuli.objects.stateControl % parent state controller
    end
    
    methods (Access = public)
        function s = state(id)
            s.id = id;
        end
        
        % called before each screen flip
        frameUpdate(s,varargin); % abstract method
        
        % called after each screen flip
        frameDraw(s,varargin); % abstract method
    end % methods
    
end % classdef