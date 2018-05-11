function sequence = buildHartleySequence(p, sn, setupRNG)
% builds a random sequence of hartley stimuli under different generating
% functions
% sequence = buildHartleySequence(p, sn, setupRNG)

if nargin < 3
    setupRNG = p.trial.(sn).rngs.conditionerRNG;
end


nFrames = p.trial.(sn).maxFrames;
sequence.kx  = zeros(nFrames,1);
sequence.ky  = zeros(nFrames,1);
sequence.tf  = zeros(nFrames,1);
sequence.phi = zeros(nFrames,1);
sequence.on  = zeros(nFrames,1);

switch p.trial.(sn).generativeModel
    case 'exponentialDecay'
        on   = ceil(exprnd(setupRNG, p.trial.(sn).OnDuration, [nFrames,1]));
        off  = round(exprnd(setupRNG, p.trial.(sn).OffDuration, [nFrames,1]));
        on   = min(on,  p.trial.(sn).MaxDuration);
        off  = min(off, p.trial.(sn).MaxDuration);
        step = on+off;
        nUpdates = find(cumsum(step)>nFrames,1);
        
        [kxg, kyg, ktfg] = ndgrid(p.trial.(sn).kxs, p.trial.(sn).kys, p.trial.(sn).tfs);
        gridIx = randi(setupRNG, numel(kxg), nUpdates, 1);
        fr=0;
        
        
        for iStim=1:nUpdates
            iFrames=fr+(1:on(iStim));
            sequence.kx(iFrames) = kxg(gridIx(iStim));
            sequence.ky(iFrames) = kyg(gridIx(iStim));
            sequence.on(iFrames) = 1;
            sequence.tf(iFrames) = ktfg(gridIx(iStim));
            sequence.phi(iFrames)= rand(setupRNG)*2*pi;
            fr=iFrames(end)+off(iStim)-1;
        end
        
    case 'pBlank'
        
        [p.trial.(sn).kxgrid, p.trial.(sn).kygrid]=meshgrid(p.trial.(sn).kxs, p.trial.(sn).kys);
        
        p.trial.(sn).kxygrid = [p.trial.(sn).kxgrid(:) p.trial.(sn).kygrid(:)];
        
        blankId = (all(p.trial.(sn).kxygrid==0, 2));
        n = size(p.trial.(sn).kxygrid, 1);
                
        p.trial.(sn).genwts = ones(1,n)* ( (1 - p.trial.(sn).pBlank) /(n-1));
        p.trial.(sn).genwts(blankId) = p.trial.(sn).pBlank;
        
        % on duration is fixed
        dur = p.trial.(sn).OnDuration;
        
        nUpdates = ceil(nFrames/dur);
        
        % set up next stimulus
        n = size(p.trial.(sn).kxygrid,1);
        ind = randsample(setupRNG, 1:n, nUpdates, true, p.trial.(sn).genwts);
        
        sequence.kx = p.trial.(sn).kxgrid(ind);
        sequence.ky = p.trial.(sn).kygrid(ind);
        sequence.tf = p.trial.(sn).tfs(randi(setupRNG, numel(p.trial.(sn).tfs), nUpdates, 1));
        sequence.phi = rand(setupRNG, nUpdates, 1)*2*pi;
        
        % resize to the frame size
        sequence.kx  = reshape(repmat(sequence.kx(:), 1, dur)', [], 1);
        sequence.ky  = reshape(repmat(sequence.ky(:), 1, dur)', [], 1);
        sequence.tf  = reshape(repmat(sequence.tf(:), 1, dur)', [], 1);
        sequence.phi = reshape(repmat(sequence.phi(:), 1, dur)', [], 1);
        
        sequence.kx  = sequence.kx(1:nFrames);
        sequence.ky  = sequence.ky(1:nFrames);
        sequence.tf  = sequence.tf(1:nFrames);
        sequence.phi = sequence.phi(1:nFrames);
        sequence.on  = ones(nFrames, 1); % on and off is captured by the stim ID
        
    case 'frozen'
        
        [p.trial.(sn).kxgrid, p.trial.(sn).kygrid]=meshgrid(p.trial.(sn).kxs, p.trial.(sn).kys);
        
        p.trial.(sn).kxygrid = [p.trial.(sn).kxgrid(:) p.trial.(sn).kygrid(:)];
        
        blankId = (all(p.trial.(sn).kxygrid==0, 2));
        n = size(p.trial.(sn).kxygrid, 1);
                
        p.trial.(sn).genwts = ones(1,n)* ( (1 - p.trial.(sn).pBlank) /(n-1));
        p.trial.(sn).genwts(blankId) = p.trial.(sn).pBlank;
        
        % on duration is fixed
        dur = p.trial.(sn).OnDuration;
        
        setupRNG = RandStream('mt19937ar', 'seed', 12345678);
        
        nUpdates = ceil(nFrames/dur);
        
        % set up next stimulus
        n = size(p.trial.(sn).kxygrid,1);
        ind = randsample(setupRNG, 1:n, nUpdates, true, p.trial.(sn).genwts);
        
        sequence.kx = p.trial.(sn).kxgrid(ind);
        sequence.ky = p.trial.(sn).kygrid(ind);
        sequence.tf = p.trial.(sn).tfs(randi(setupRNG, numel(p.trial.(sn).tfs), nUpdates, 1));
        sequence.phi = rand(setupRNG, nUpdates, 1)*2*pi;
        
        % resize to the frame size
        sequence.kx  = reshape(repmat(sequence.kx(:), 1, dur)', [], 1);
        sequence.ky  = reshape(repmat(sequence.ky(:), 1, dur)', [], 1);
        sequence.tf  = reshape(repmat(sequence.tf(:), 1, dur)', [], 1);
        sequence.phi = reshape(repmat(sequence.phi(:), 1, dur)', [], 1);
        
        sequence.kx  = sequence.kx(1:nFrames);
        sequence.ky  = sequence.ky(1:nFrames);
        sequence.tf  = sequence.tf(1:nFrames);
        sequence.phi = sequence.phi(1:nFrames);
        sequence.on  = ones(nFrames, 1); % on and off is captured by the stim ID
        
        nRepeats = 4;
        sequenceLength = floor(nFrames/nRepeats);
        sequence.kx(1:sequenceLength*nRepeats)  = repmat(sequence.kx(1:sequenceLength), nRepeats, 1);
        sequence.ky(1:sequenceLength*nRepeats)  = repmat(sequence.ky(1:sequenceLength), nRepeats, 1);
        sequence.tf(1:sequenceLength*nRepeats)  = repmat(sequence.tf(1:sequenceLength),  nRepeats, 1);
        sequence.phi(1:sequenceLength*nRepeats) = repmat(sequence.phi(1:sequenceLength), nRepeats, 1);
        
        
    otherwise
        error('p.trial.(sn).generativeModel must be ''exponential Decay'' or ''pBlank''')
        
end



