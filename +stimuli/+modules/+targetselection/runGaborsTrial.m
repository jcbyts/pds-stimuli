function p=runGaborsTrial(p,state, sn)
% runTrial operates a trial of the target selection protocol
% To call, use 
if nargin<3
    sn='targetselection';
end

if nargin < 1 % no arguments in: courtesy print default arguments
   
end

% --- switch PLDAPS trial states
switch state
    
    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol (I know.
        % There should be a way to make this automatic, but can't think of
        % an easy way)
        
        stimuli.setupDefaultFrameStates(p, sn)
        
        p = stimuli.setupRandomSeed(p, sn);
    
    % --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- setup default parameters that don't depend on other variables
        defaultArgs = {...
            'RfCenterXy',               [5, -5], ...    % degrees
            'speed',                    nan, ...        % drift speed (deg/sec)
            'contrast',                 .25, ...        % - 0.5 yo 0.5
            'difficulty',               nan, ...        % degrees (range of uniform distribution over direction)
            'tf',                       10, ...        % dots / deg^2 / sec 
            'sf',                       2, ...
            'lifetime',                 nan, ...         % frames
            'maxBandwidth',             0.0, ...
            'minBandwidth',             0.0, ...
            'numBandwidths',            1, ...
            'numDirs',                  8, ...
            'CenterAngle',              [0 180], ...
            'rewardUpdateFun',          @stimuli.modules.targetselection.rewardUpdateSwitchRule, ...
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
            'fixationJitter',           false, ...
            'fixationJitterSize',       0, ...
            'fixationX',                0, ...
            'fixationY',                0, ...
            'fixPointRadius',           0.3, ...
            'fixPointDim',              0.1, ...
            'fixWinRadius',             1.8, ...
            'fixFlashCnt',              round(0.250*p.trial.display.frate), ...
            'fixGracePeriod',           0.050, ...
            'trialTimeout',             3, ... % seconds to obtain fixation
            };
        
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end 
        end
        
        % --- Default variables that depend on others being set
        if ~isfield(p.trial.(sn), 'dotApertureRadius')
            p.trial.(sn).dotApertureRadius = norm(p.trial.(sn).RfCenterXy)/3;     % degrees
        end
        
        if ~isfield(p.trial.(sn), 'targWinRadius')
            p.trial.(sn).targWinRadius = p.trial.(sn).dotApertureRadius;
        end
        
        % -------------------------------------------------------------------------
        % --- setup stimuli and prepare to run
               
        % --- Fixation
        if ~(isfield(p.trial.(sn), 'hFix') && isa(p.trial.(sn).hFix, 'stimuli.objects.target'))
            p.trial.(sn).hFix   = stimuli.objects.fixation('position', p.trial.display.ctr(1:2));
        end
        
        % --- Reward Face
        if ~(isfield(p.trial.(sn), 'hFace') && isa(p.trial.(sn).hFix, 'stimuli.objects.textures'))
            p.trial.(sn).hFace  = stimuli.objects.face(p);
            p.trial.(sn).hFace.id   = p.trial.(sn).faceIndex;
        end
        
        % --- Targs
        if ~isfield(p.trial.(sn), 'hTargs')
            p.trial.(sn).hTargs(1)   = stimuli.objects.gaborTarget();
            p.trial.(sn).hTargs(2)   = stimuli.objects.gaborTarget();
        end
             

	% --- Called before the main trial loop. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
         
        stimuli.modules.targetselection.trialSetup(p, sn);

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
       
        p.trial.(sn).states.frameUpdate(p, sn);
    
	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).states.frameDraw(p,sn);
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        % this is where we update the reward rates
%         hasData = ~cellfun(@isempty, p.data(:));

        % --- Update reward
        hasData  = cellfun(@(x) isfield(x, sn), p.data(:)); % find trials that have this module
        choices  = cellfun(@(x) x.(sn).dotsChosen, p.data(hasData));   % get choices from those trials
        rewarded = cellfun(@(x) x.(sn).rewardAmount, p.data(hasData)); % get trial outcome
        choices = [choices p.trial.(sn).dotsChosen]; % concatenate with current trial
        rewarded = [rewarded p.trial.(sn).rewardAmount]; % concatenate with current trial
        
            
        % run the reward update rule
        [p.trial.(sn).rewardDot1Rate, p.trial.(sn).rewardDot2Rate, p.trial.(sn).stimVisible] = ...
            p.trial.(sn).rewardUpdateFun(choices, p.trial.(sn).rewardDot1Rate, p.trial.(sn).rewardDot2Rate, ...
                                           p.trial.(sn).stimVisible,p.trial.(sn).rewardUpdateArgs{:},...
                                           p.trial.(sn).trialsToSwap);
                
        %upload to conditions for next trial to live on
        stimuli.updateConditions(p, sn, 'rewardDot1Rate', p.trial.(sn).rewardDot1Rate);
        stimuli.updateConditions(p, sn, 'rewardDot2Rate', p.trial.(sn).rewardDot2Rate);
        stimuli.updateConditions(p, sn, 'stimVisible', p.trial.(sn).stimVisible);


        %         figure(1); clf
%         for i = 1:2
%             ix = find(choices==i);
%             
%             wasRewarded = rewarded(ix)>0;
%             
%             plot(ix(wasRewarded), i*ones(1,sum(wasRewarded)), 'og'); hold on
%             plot(ix(~wasRewarded), i*ones(1,sum(~wasRewarded)), 'or');
%         end
            
        
end % switch

end % function