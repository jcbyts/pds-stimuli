function p=defaultHartleyTrial(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='hartley';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        
    case p.trial.pldaps.trialStates.frameUpdate
        
        if p.trial.(sn).on(p.trial.iFrame)
            p.trial.(sn).hHart.kx=p.trial.(sn).kx(p.trial.iFrame);
            p.trial.(sn).hHart.ky=p.trial.(sn).ky(p.trial.iFrame);
            p.trial.(sn).hHart.tf=p.trial.(sn).tf(p.trial.iFrame);
%             p.trial.(sn).phi(p.trial.iFrame)=mod(2*pi*p.trial.(sn).hHart.tf*p.trial.iFrame*p.trial.display.ifi, 2*pi);
            p.trial.(sn).hHart.phi=p.trial.(sn).phi(p.trial.iFrame);
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on(p.trial.iFrame)
            p.trial.(sn).hHart.draw
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % BLEND FUNCTION MUST BE GL_ONE, GL_ONE FOR THIS MODULE TO WORK
        p.trial.display.sourceFactorNew      = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        

        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        p.trial.(sn).hHart.contrast = p.trial.(sn).contrast;
        p.trial.(sn).hHart.M = p.trial.(sn).M;
        

        p.trial.(sn).hHart.setup;
            
        if isfield(p.trial.(sn), 'kx')
            return
        end

            
            p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
            p.trial.(sn).count = 1; % number shown
            p.trial.(sn).kx  = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
            p.trial.(sn).ky  = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
            p.trial.(sn).on  = zeros(p.trial.(sn).maxFrames,p.trial.(sn).count);
            p.trial.(sn).phi = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
            p.trial.(sn).tf  = nan(p.trial.(sn).maxFrames,  p.trial.(sn).count);
            
            % exponential decay
            p.trial.(sn).M = 1; % grid size

            freqs = sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);
            p.trial.(sn).kxs = freqs;
            p.trial.(sn).kys = freqs;
            
            % generate exponentially distributed random variable using the
            % exponential inverse cdf -- we call it this way so that we can
            % pass in the random number generater argument
            rnd = rand(setupRNG,  [p.trial.(sn).maxFrames,1]); % uniform random
            on  = ceil( -p.trial.(sn).OnDuration .* log(rnd)); % convert to exponential
            
            rnd = rand(setupRNG,  [p.trial.(sn).maxFrames,1]); % uniform random
            off = ceil( -p.trial.(sn).OffDuration .* log(rnd)); % convert to exponential
            
            % truncate
            on  = min(on,  p.trial.(sn).MaxDuration);
            off = min(off, p.trial.(sn).MaxDuration);
            
            % precompute stimulus
            step = on + off;
            nUpdates = find(cumsum(step) > p.trial.(sn).maxFrames, 1);
            
            [kxg, kyg, ktfg] = ndgrid(p.trial.(sn).kxs, p.trial.(sn).kys, p.trial.(sn).tfs);
            
            gridIx = randi(setupRNG, numel(kxg), nUpdates, 1);
            
            fr=0;
            for iStim=1:nUpdates
                iFrames=fr+(1:on(iStim));
                p.trial.(sn).kx(iFrames)  = kxg(gridIx(iStim));
                p.trial.(sn).ky(iFrames)  = kyg(gridIx(iStim));
                p.trial.(sn).on(iFrames)  = 1;
                p.trial.(sn).tf(iFrames)  = ktfg(gridIx(iStim));
                p.trial.(sn).phi(iFrames) = rand(setupRNG)*2*pi;
                fr = iFrames(end) + off(iStim) - 1;
            end
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- set up default parameters
        defaultArgs = {...
            'OnDuration',           2, ... % time constant of on (frames)
            'OffDuration',          2, ...
            'MaxDuration',          20, ... % maximum time on (frames), truncates the exponential
            'contrast',           	.2, ... % Michelson contrast of the gratings (DEPENDS ON BLEND FUNCTION)
            'tfs',                  0, ...  % temporal frequencies showns
            'nOctaves',             5, ...  % number of octaves to show above base frequency
            'Freq0',                .1, ... % Base frequence (cycles/deg)
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
        
        p = stimuli.setupRandomSeed(p, sn);
        
        % --- instantiate Hartley object
        p.trial.(sn).hHart = stimuli.hartley(p);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        ix = 1:p.trial.iFrame;
        p.trial.(sn).kx = p.trial.(sn).kx(ix,:);
        p.trial.(sn).ky = p.trial.(sn).ky(ix,:);
        p.trial.(sn).on = p.trial.(sn).on(ix,:);
        p.trial.(sn).tf = p.trial.(sn).tf(ix,:);
        p.trial.(sn).phi = p.trial.(sn).phi(ix,:);

        
end