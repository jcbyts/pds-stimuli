function p=gratingTrialRevco(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='grating';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
    defaultArgs = {...
        'OnDuration',           'Frame Duration. If "exponential Decay" mode, time constant of on (frames)', ...
        'OffDuration',          'If "exponential Decay" mode,time constant of inter stimulus interval (frames)',...
        'MaxDuration',          'maximum time on (frames), truncates the exponential', ...
        'contrast',           	'Michelson contrast of the gratings', ...
        'tfs     ',             'temporal frequencies to show', ...
        'sfs     ',             'spatial frequencies to show', ...
        'numOrientations',      'number of orientations', ...
        'generativeModel',      'generative model to use for the sequence', ...
        'pBlank    ',           'probability of a blank stimulus, if using pBlank generative model', ...
        };
    fprintf('No arguments passed in: call from within pldaps\n')
    fprintf('<strong>Optional Parameters:</strong>\n')
    fprintf('<strong>%s</strong>\t\t\t%s\n', defaultArgs{:})
    return
end

switch state
        
    %--------------------------------------------------------------------------
    % --- Before Opening the screen: Setup the random seed and turn on the
    %     default pldaps frame states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        stimuli.setupDefaultFrameStates(p, sn);
        stimuli.setupRandomSeed(p, sn);
        
    %--------------------------------------------------------------------------
    % --- After screen is open: Setup default parameters
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- set up default parameters
        defaultArgs = {...
            'OnDuration',           2, ... % on duration. If "exponential decay", time constant of on (frames)
            'OffDuration',          2, ...
            'MaxDuration',          20, ...       % maximum time on (frames), truncates the exponential
            'contrast',           	.2, ...       % Michelson contrast of the gratings (DEPENDS ON BLEND FUNCTION)
            'tfs',                  0, ...        % temporal frequencies showns
            'sfs',                  2, ...        % spatial frequencies shown
            'numOrientations',      12, ...       % Base frequence (cycles/deg)
            'generativeModel',      'pBlank', ... % which generative model to use for the sequence
            'pBlank',               0, ...        % proportion of stimuli that are blank
            };
        
        % step through argument pairs and add them to the module
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end
        
        
        
    %--------------------------------------------------------------------------
    % --- Trial Setup: pre-allocate important variables for storage and
    % update the object
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.(sn).orientations = 0:(180/p.trial.(sn).numOrientations):(180 - (180/p.trial.(sn).numOrientations));
        [p.trial.(sn).origrid, p.trial.(sn).sfgrid]=meshgrid(p.trial.(sn).orientations, p.trial.(sn).sfs);
        
        % --- instantiate Hartley object
        p.trial.(sn).hHart = stimuli.objects.grating(p, 'position', p.trial.display.ctr(1:2));
        
        % necessary variable
        p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).hHart.contrast = p.trial.(sn).contrast;
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG = RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
                
        % setup sequence
        p.trial.(sn).sequence.ori = p.trial.(sn).orientations(randi(p.trial.(sn).rngs.conditionerRNG, p.trial.(sn).numOrientations, p.trial.(sn).maxFrames, 1));
        p.trial.(sn).sequence.sf  = p.trial.(sn).sfs(randi(p.trial.(sn).rngs.conditionerRNG, numel(p.trial.(sn).sfs), p.trial.(sn).maxFrames, 1));
        p.trial.(sn).sequence.tf  = zeros(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).sequence.phi = zeros(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).sequence.on  = rand(p.trial.(sn).rngs.conditionerRNG, p.trial.(sn).maxFrames, 1)>p.trial.(sn).pBlank;
        
        % preallocate variables
        p.trial.(sn).ori = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).on  = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).sf  = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).phi = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).tf  = nan(p.trial.(sn).maxFrames, 1);
        
        p.trial.(sn).sequenceFrame = 0;
        p.trial.(sn).LastSwitch = 1;
        p.trial.(sn).switchRefractoryPeriod = 4; % frames
        
	%--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % increment sequence counter
        if (p.trial.iFrame - p.trial.(sn).LastSwitch) > p.trial.(sn).OnDuration
            
            % step in sequence
            p.trial.(sn).sequenceFrame = p.trial.(sn).sequenceFrame + 1; % skip to next frame
            p.trial.(sn).LastSwitch = p.trial.iFrame;
            
        end
        
        
        if p.trial.(sn).sequenceFrame > 0    
            % In this default version, we will simply step through the sequence
            seq = p.trial.(sn).sequence;
            p.trial.(sn).on(p.trial.iFrame)  = seq.on(p.trial.(sn).sequenceFrame);
            p.trial.(sn).ori(p.trial.iFrame) = seq.ori(p.trial.(sn).sequenceFrame);
            p.trial.(sn).sf(p.trial.iFrame)  = seq.sf(p.trial.(sn).sequenceFrame);
            p.trial.(sn).tf(p.trial.iFrame)  = seq.tf(p.trial.(sn).sequenceFrame);
            p.trial.(sn).phi(p.trial.iFrame) = seq.phi(p.trial.(sn).sequenceFrame);
            
            
            p.trial.(sn).hHart.stimValue = double(p.trial.(sn).on(p.trial.iFrame));
            p.trial.(sn).hHart.ori       = p.trial.(sn).ori(p.trial.iFrame);
            p.trial.(sn).hHart.sf        = p.trial.(sn).sf(p.trial.iFrame);
            p.trial.(sn).hHart.tf        = p.trial.(sn).tf(p.trial.iFrame);
            p.trial.(sn).hHart.phi       = p.trial.(sn).phi(p.trial.iFrame);
        end
        
    %--------------------------------------------------------------------------
    % --- Draw the frame: Just call the hartley object's drawing method    
    case p.trial.pldaps.trialStates.frameDraw

        p.trial.(sn).hHart.frameDraw(p)
        
    %--------------------------------------------------------------------------
    % --- After the trial: cleanup workspace for saving
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        % clear textures from graphics card memory
        p.trial.(sn).hHart.trialCleanup(p);
        
        p.trial.(sn) = rmfield(p.trial.(sn), 'sequence');
        p.trial.(sn) = rmfield(p.trial.(sn), 'sfgrid');
        p.trial.(sn) = rmfield(p.trial.(sn), 'origrid');
        
        % only save frames that were shown
        ix = 1:p.trial.iFrame;
        p.trial.(sn).ori = p.trial.(sn).ori(ix,:);
        p.trial.(sn).sf  = p.trial.(sn).sf(ix,:);
        p.trial.(sn).on  = p.trial.(sn).on(ix,:);
        p.trial.(sn).tf  = p.trial.(sn).tf(ix,:);
        p.trial.(sn).phi = p.trial.(sn).phi(ix,:);
        
end