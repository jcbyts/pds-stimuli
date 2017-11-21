function varargout = rewardUpdateSwitchRule(choices, rate1, rate2, Param)
% varargout = rewardUpdateSwitchRule(choices, rate1, rate2, Param)

% simplest way to start is to switch randomly with some improbable rate
assert(Param > 0 & Param < 1, 'Param governs switch rate, must be between 0 and 1');

if rand < Param % switch reward
    varargout{1} = rate2;
    varargout{2} = rate1;
else
    varargout{1} = rate1;
    varargout{2} = rate2;
end
    
