% abstract class for stimulus paradigm states

% 07-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.irg>
  
classdef (Abstract) state < handle
  % Abstract class for a stimulus paradigm states.
  %
  % To see the public properties of this class, type
  %
  %   properties(marmoview.state)
  %
  % To see a list of methods, type
  %
  %   methods(marmoview.state)
  %
  % The class constructor can be called with a range of arguments:
  %
  %   None.

  % note: the @state class together with the @trial class implement the
  %       so called 'state' pattern... the @trial object provides the
  %       context while the @state class provides the state specific
  %       behaviour and transition logic
  
%   properties (Access = protected)
  properties (Access = {?stimuli.trial,?stimuli.state})
    id@double; % state identifier
    
    hTrial@stimuli.trial; % the @trial context
  end
  
  methods (Access = public)
    function s = state(id,hTrial)
      s.id = id;
      s.hTrial = hTrial;
    end
  
    % called before each screen flip
    beforeFrame(s,varargin); % abstract method
    
    % called after each screen flip
    afterFrame(s,t,varargin); % abstract method
  end % methods

end % classdef