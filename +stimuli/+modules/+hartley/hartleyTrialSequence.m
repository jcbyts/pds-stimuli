function p=hartleyTrialSequence(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception
% Each presentation has a duration (in frames). Stimuli are drawn from a
% weighted distribution (primarily so that blanks can be overrepresented,
% however, this could also be used for adaptation experiments)

if nargin<3
    sn='hartley';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
    defaultArgs = {...
        'OnDuration',           'fixed duration on (frames)', ...
        'OffDuration',          'fixed duration inter stimulus interval (frames)',...
        'MaxDuration',          'maximum time on (frames), truncates the exponential', ...
        'contrast',           	'Michelson contrast of the gratings', ...
        'tfs',                  'temporal frequencies showns', ...
        'nOctaves',             'number of octaves to show above base frequency', ...
        'Freq0',                'Base frequence (cycles/deg)', ...
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
        
        % BLEND FUNCTION MUST BE GL_ONE, GL_ONE FOR THIS MODULE TO WORK
        p.trial.display.sourceFactorNew      = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        % --- set up default parameters
        defaultArgs = {...
            'OnDuration',           2, ... % time constant of on (frames)
            'OffDuration',          2, ...
            'MaxDuration',          20, ... % maximum time on (frames), truncates the exponential
            'contrast',           	.2, ... % Michelson contrast of the gratings (DEPENDS ON BLEND FUNCTION)
            'tfs',                  0, ...  % temporal frequencies showns
            'nOctaves',             5, ...  % number of octaves to show above base frequency
            'Freq0',                .1, ... % Base frequence (cycles/deg)
            'weightmode',     'pBlank', ...
            'pBlank',               .1, ...
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
        [p.trial.(sn).kxgrid, p.trial.(sn).kygrid] = meshgrid(p.trial.(sn).kxs, p.trial.(sn).kys);
        
        % --- instantiate Hartley object
        p.trial.(sn).hHart = stimuli.objects.hartleybase(p, 'maskType', 1, 'maskParam', 2, 'position', p.trial.display.ctr(1:2));
        
        
    %--------------------------------------------------------------------------
    % --- Trial Setup: pre-allocate important variables for storage and
    %     update the object
    case p.trial.pldaps.trialStates.trialSetup
        

        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        
        p.trial.(sn).hHart.contrast = p.trial.(sn).contrast;
        p.trial.(sn).hHart.M = p.trial.(sn).M;
        
        
        % preallocate variables
        p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).count = 1; % number shown
        p.trial.(sn).kx  = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
        p.trial.(sn).ky  = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
        p.trial.(sn).on  = zeros(p.trial.(sn).maxFrames,p.trial.(sn).count);
        p.trial.(sn).phi = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
        p.trial.(sn).tf  = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
        
        p.trial.(sn).M = 1; % grid size
        
        freqs = sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);
        p.trial.(sn).kxs = freqs;
        p.trial.(sn).kys = freqs;
        
        [p.trial.(sn).kxgrid, p.trial.(sn).kygrid]=meshgrid(p.trial.(sn).kxs, p.trial.(sn).kys);
        
        p.trial.(sn).kxygrid = [p.trial.(sn).kxgrid(:) p.trial.(sn).kygrid(:)];
        
        switch p.trial.(sn).weightmode
            
            case 'pBlank'
                
                blankId = find(all(p.trial.(sn).kxygrid==0, 2));
                n = size(p.trial.(sn).kxygrid, 1);
                
                p.trial.(sn).genwts = ones(1,n)* ( (1 - p.trial.(sn).pBlank) /(n-1));
                p.trial.(sn).genwts(blankId) = p.trial.(sn).pBlank; %#ok<FNDSB>
                
            otherwise
                n = size(p.trial.(sn).kxygrid, 1);
                p.trial.(sn).genwts = ones(1, n)/n;
                
                
                
        end
        
        p.trial.(sn).nextSwitch = 1; % start hartley on frame 1
        
	%--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw
    case p.trial.pldaps.trialStates.framePrepareDrawing
        % In this default version of hartely, we will switch the stimulus
        % after a random delay that was set previously by the nextSwitch
        % variable
        
        d = p.trial.(sn).nextSwitch - p.trial.iFrame;
            if d <= 0 % time to swtich

                                      
                p.trial.(sn).hHart.stimValue = 1; % turn stimulus off
                
                % on duration is fixed
                dur = p.trial.(sn).OnDuration;
                
                % set up next stimulus
                n = size(p.trial.(sn).kxygrid,1);
                ind = randsample(p.trial.(sn).rngs.conditionerRNG, 1:n, 1, true, p.trial.(sn).genwts);
                p.trial.(sn).hHart.kx = p.trial.(sn).kxygrid(ind,1);
                p.trial.(sn).hHart.ky = p.trial.(sn).kxygrid(ind,2);
                p.trial.(sn).hHart.tf = p.trial.(sn).tfs(randi(p.trial.(sn).rngs.conditionerRNG, numel(p.trial.(sn).tfs)));
                
                p.trial.(sn).hHart.phi = rand(p.trial.(sn).rngs.conditionerRNG)*2*pi;
                        
                
                p.trial.(sn).nextSwitch = p.trial.iFrame + dur;
                
            end
            
            % save the current values
            p.trial.(sn).on(p.trial.iFrame) = p.trial.(sn).hHart.stimValue;
            
            if p.trial.(sn).on(p.trial.iFrame)
                p.trial.(sn).kx(p.trial.iFrame)  = p.trial.(sn).hHart.kx;
                p.trial.(sn).ky(p.trial.iFrame)  = p.trial.(sn).hHart.ky;
                p.trial.(sn).tf(p.trial.iFrame)  = p.trial.(sn).hHart.tf;
                p.trial.(sn).phi(p.trial.iFrame) = p.trial.(sn).hHart.phi;
            end        
        
    %--------------------------------------------------------------------------
    % --- Draw the frame: Just call the hartley object's drawing method    
    case p.trial.pldaps.trialStates.frameDraw

        p.trial.(sn).hHart.frameDraw(p)
        

    %--------------------------------------------------------------------------
    % --- After the trial: cleanup workspace for saving
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        % only save frames that were shown
        ix = 1:p.trial.iFrame;
        p.trial.(sn).kx  = p.trial.(sn).kx(ix,:);
        p.trial.(sn).ky  = p.trial.(sn).ky(ix,:);
        p.trial.(sn).on  = p.trial.(sn).on(ix,:);
        p.trial.(sn).tf  = p.trial.(sn).tf(ix,:);
        p.trial.(sn).phi = p.trial.(sn).phi(ix,:);

        
end