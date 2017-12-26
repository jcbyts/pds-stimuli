function setupDefaultFrameStates(p, sn, varargin)
% turn on default states for specified module
% setupDefaultFrameStates(p, sn, [requestedStates])
% Input:
%   p   - pldaps object
%   sn  - module name
%   requestedStates (optional) - cell array of requested states

if nargin > 2
    requestedStates = varargin{1};
else
    requestedStates = {...
        'experimentPostOpenScreen',...
        'trialSetup',...
        'framePrepareDrawing',...
        'frameDraw',...
        'trialCleanUpandSave',...
        };
end

p.defaultParameters.(sn).stateFunction.acceptsLocationInput = true; % is this necessary
% setup states that will be called by this module

for iState = 1:numel(requestedStates)
    stateName = requestedStates{iState};
    p.defaultParameters.(sn).stateFunction.requestedStates.(stateName) = true;
end