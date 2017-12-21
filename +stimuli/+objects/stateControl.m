% handle class for behavioral state management
classdef stateControl < handle % handle class self references in memory
    % class for a stimulus paradigm trial.
    %
    % To see the public properties of this class, type
    %
    %   properties(stimuli.stateControl)
    %
    % To see a list of methods, type
    %
    %   methods(stimuli.stateControl)
    %
    % The class constructor can be called with a range of arguments:
    %
    %   None.
    
    % note: the @stateControl class together with the @state class implement
    %       the 'state' pattern... the @stateControl object provides the
    %       context while the @state class provides the state specific
    %       behaviour and transition logic
    %
    %       we minimize overhead associated with creating the @state objects
    %       by pre-allocating the @state objects in the constructor and then
    %       assigning the appropriate handles to currentState as we progress
    %       through the trial
    
    properties (Access = private) % private. These are managed internally.
        stateIds@double             % array of all state ids
        currentState@stimuli.state; % pointer to current state
        stateHandles@cell           % cell array of @state object handles
    end
    
    properties (Access = {?stimuli.stateControl,?stimuli.state}) % only accessible by this class and the state class
%         txTimes@double; % state transition times
        txLog@cell
%         txCtr@double
    end
    
    % dependent properties...
    properties (SetObservable, Dependent, SetAccess = private, GetAccess = public)
        stateId@double;
    end
    
    methods % get/set dependent properties
        % dependent property get methods
        function value = get.stateId(o)
            value = o.currentState.id;
        end
        
        function value = get.txLog(o)
            value = o.txLog;
        end
        
    end
    
    methods (Access = public)
        %     function o = trial(varargin),
        %     end
        
        function value = getLog(o, id)
            % get the timestamps for a particular state
            % log = o.getLog(id)
            if nargin ==1
                value = o.txLog;
                return
            end
            
            ii = o.stateIds == id;
            value = o.txLog{ii};
        end
        
        % called before each screen flip
        function frameDraw(o,varargin)
            o.currentState.frameDraw(varargin{:});
        end
        
        % called after each screen flip
        function frameUpdate(o,varargin)
            o.currentState.frameUpdate(varargin{:});
        end
        
        % methods for manipulating the pool of @state objects
        function addState(o,h)
            assert(~any(ismember(o.stateIds,h.id)),'Duplicate state, id = %i',h.id);
            
            n = length(o.stateIds);
            
            o.stateIds(n+1) = h.id;
            o.stateHandles{n+1} = h;
            h.sc = o;
            
%             o.txTimes(n+1) = NaN;
            o.txLog{n+1} = []; %nan(1,10e3);
%             o.txCtr(n+1) = 0;
        end
        
        function setState(o,stateId,varargin) % FIXME; varargin?
            % set the current state...
            ii = o.stateIds == stateId;
            o.currentState = o.stateHandles{ii};
            
            % log current state
%             o.txCtr(ii) = o.txCtr(ii)+1;
%             o.txLog{ii}(o.txCtr(ii)) = GetSecs;
            if nargin > 2
                o.txLog{ii}(end + 1) = varargin{1};
            else
                o.txLog{ii}(end + 1) = GetSecs; %[varargin{:}];
            end
%             o.txLog{ii}(:,end + 1) = [varargin{:}];
        end
        
        % get/set methods for the state transition times
        function t = getTxTime(o,varargin)
            id = o.stateId; % default: current state...
            if nargin == 2
                id = varargin{1};
            end
            
            ii = o.stateIds == id;
            if isempty(o.txLog{ii})
                t = nan;
                return
            end
            
            t  = o.txLog{ii}(end);
        end
        
%         function setTxTime(o,t,varargin)
%             id = o.stateId; % default: current state...
%             if nargin == 3
%                 id = varargin{1};
%             end
%             
%             ii = o.stateIds == id;
%             o.txTimes(ii) = t;
%         end
        
        function cleanup(o)
           n = numel(o.txLog);
           for ii = 1:n
              o.txLog{ii}(isnan(o.txLog{ii})) = [];
           end
        end
        
    end % public methods
    
end % classdef