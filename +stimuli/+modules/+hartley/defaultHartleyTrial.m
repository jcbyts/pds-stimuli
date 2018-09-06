function p=defaultHartleyTrial(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='hartley';
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
        'tfs     ',                  'temporal frequencies showns', ...
        'nOctaves',             'number of octaves to show above base frequency', ...
        'Freq0    ',                'Base frequence (cycles/deg)', ...
        'generativeModel',      'generative model to use for the sequence', ...
        'pBlank    ',               'probability of a blank stimulus, if using pBlank generative model', ...
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
            'nOctaves',             5, ...        % number of octaves to show above base frequency
            'Freq0',                .1, ...       % Base frequence (cycles/deg)
            'generativeModel',      'pBlank', ... % which generative model to use for the sequence
            'pBlank',               0, ... % proportion of stimuli that are blank
            };
        
        % step through argument pairs and add them to the module
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end
        
        
        p.trial.(sn).M   = 1;
        freqs = sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);
        p.trial.(sn).kxs = freqs;
        p.trial.(sn).kys = freqs;
        
        
        p.trial.(sn).count = 1;
        [p.trial.(sn).kxgrid, p.trial.(sn).kygrid]=meshgrid(p.trial.(sn).kxs, p.trial.(sn).kys);
        
        % --- instantiate Hartley object
        p.trial.(sn).hHart = stimuli.objects.hartleybase(p, 'position', p.trial.display.ctr(1:2));
        
    %--------------------------------------------------------------------------
    % --- Trial Setup: pre-allocate important variables for storage and
    % update the object
    case p.trial.pldaps.trialStates.trialSetup
        
        % --- instantiate Hartley object
        if ~isfield(p.trial.(sn), 'hHart')
            p.trial.(sn).hHart = stimuli.objects.hartleybase(p, 'position', p.trial.display.ctr(1:2));
        end
        
        % necessary variable
        p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).hHart.contrast = p.trial.(sn).contrast;
        p.trial.(sn).M = 1; % grid size
        p.trial.(sn).hHart.M = p.trial.(sn).M;
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG = RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        
        % Isn't this already done? Shouldn't we restrict changing kxs
        % during a session?
        freqs = sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);
        p.trial.(sn).kxs = freqs;
        p.trial.(sn).kys = freqs;
        
        % setup sequence
        p.trial.(sn).sequence = stimuli.modules.hartley.buildHartleySequence(p, sn);
        
        % preallocate variables
        p.trial.(sn).kx  = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).ky  = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).on  = zeros(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).phi = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).tf  = nan(p.trial.(sn).maxFrames, 1);
        p.trial.(sn).sequenceFrame = 0;
        
	%--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % increment sequence counter
        p.trial.(sn).sequenceFrame = p.trial.(sn).sequenceFrame + 1;
        
        if p.trial.(sn).sequenceFrame > 0    
            % In this default version, we will simply step through the sequence
            seq = p.trial.(sn).sequence;
            p.trial.(sn).on(p.trial.iFrame)  = seq.on(p.trial.(sn).sequenceFrame);
            p.trial.(sn).kx(p.trial.iFrame)  = seq.kx(p.trial.(sn).sequenceFrame);
            p.trial.(sn).ky(p.trial.iFrame)  = seq.ky(p.trial.(sn).sequenceFrame);
            p.trial.(sn).tf(p.trial.iFrame)  = seq.tf(p.trial.(sn).sequenceFrame);
            p.trial.(sn).phi(p.trial.iFrame) = seq.phi(p.trial.(sn).sequenceFrame);
            
            
            p.trial.(sn).hHart.stimValue = p.trial.(sn).on(p.trial.iFrame);
            p.trial.(sn).hHart.kx        = p.trial.(sn).kx(p.trial.iFrame);
            p.trial.(sn).hHart.ky        = p.trial.(sn).ky(p.trial.iFrame);
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
        
        % only save frames that were shown
        ix = 1:p.trial.iFrame;
        p.trial.(sn).kx  = p.trial.(sn).kx(ix,:);
        p.trial.(sn).ky  = p.trial.(sn).ky(ix,:);
        p.trial.(sn).on  = p.trial.(sn).on(ix,:);
        p.trial.(sn).tf  = p.trial.(sn).tf(ix,:);
        p.trial.(sn).phi = p.trial.(sn).phi(ix,:);
        
end