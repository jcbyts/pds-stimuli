function defaultParameters(p, sn)

if nargin < 2
    sn='targetselection';
end



% --- setup default parameters that don't depend on other variables
defaultArgs = {...
    'RfCenterXy',               [5, -5], ...    % degrees
    'speed',                    nan, ...        % drift speed (deg/sec)
    'contrast',                 .25, ...        % - 0.5 yo 0.5
    'difficulty',               nan, ...        % degrees (range of uniform distribution over direction)
    'dotSize',                  0.1, ...        % degrees (diameter)
    'dotDensity',               400, ...        % dots / deg^2 / sec
    'dotSpeed',                 8.0, ...        % dot speed (deg/sec)
    'dotContrast',              -0.5, ...       % - 0.5 yo 0.5
    'dotRange',                 0.0, ...        % degrees (range of uniform distribution over direction)
    'dotContrast',              5, ...
    'dotLifetime',              12, ...         % frames
    'tf',                       10, ...        % dots / deg^2 / sec 
    'sf',                       2, ...
    'lifetime',                 nan, ...         % frames
    'maxBandwidth',             0.0, ...
    'minBandwidth',             0.0, ...
    'numBandwidths',            1, ...
    'numDirs',                  8, ...
    'CenterAngle',              [0 180], ...
    'rewardUpdateFun',          @stimuli.modules.dotselection.rewardUpdateSwitchRule, ...
    'rewardUpdateArgs',         {.1}, ...
    'rewardForFixation',        false, ...
    'rewardFaceDuration',       0, ...
    'yokeDirections',           false, ...      % yoke the direction of dots for dots1 and dots2
    'rewardDot1Rate',           1, ...
    'rewardDot2Rate',           0, ...
    'maxRewardCnt',             2, ...          % max drops of juice
    'faceIndex',                1, ...
    'minFixPreStim',            0.1, ...
    'maxFixPreStim',            0.2, ...
    'minFixPostStim',           0.1, ...
    'maxFixPostStim',           0.2, ...        % seconds (wrt dot motion onset)
    'fixHoldTau',               0.2, ...        % seconds(time constant of exponential)
    'choiceGracePeriod',        1.4, ...        % grace period for decision time (seconds)
    'choiceHoldDuration',       0.025, ...      % minimum choice hold duration (seconds)
    'iti',                      1.0, ...
    'rewardcount',              zeros(1,2), ... % two targets, only two states
    'rewardtravel',             4, ...          % must choose this many times before move
    'rewardtransit',            1.0, ...        % prob to transition reward state
    'stimVisible',              [1 0 1 0 0], ... % will the dots be shown
    'trialsToSwap',             16, ...     % if dual targs, stay this long in on one side
    };

for iArg = 1:2:numel(defaultArgs)
    
    field = defaultArgs{iArg};
    val   = defaultArgs{iArg+1};
    
    if ~isfield(p.trial.(sn), field)
        p.trial.(sn).(field) = val;
    end
end