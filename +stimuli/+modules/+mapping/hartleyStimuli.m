function p=hartleyStimuli(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='Hartley';
end


switch state

    %--------------------------------------------------------------------------
    % --- Before Opening the screen: Setup the random seed and turn on the
    %     default pldaps frame states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        stimuli.setupDefaultFrameStates(p, sn);
        stimuli.setupRandomSeed(p, sn);

        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        if p.trial.(sn).on(p.trial.iFrame)
            p.trial.(sn).n.kx=p.trial.(sn).kx(p.trial.iFrame);
            p.trial.(sn).n.ky=p.trial.(sn).ky(p.trial.iFrame);
            p.trial.(sn).n.tf=p.trial.(sn).tf(p.trial.iFrame);
%             p.trial.(sn).phi(p.trial.iFrame)=mod(2*pi*p.trial.(sn).n.tf*p.trial.iFrame*p.trial.display.ifi, 2*pi);
            p.trial.(sn).n.phi=p.trial.(sn).phi(p.trial.iFrame);
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on(p.trial.iFrame)
            p.trial.(sn).n.draw
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        
        
%         if p.trial.(sn).on
            p.trial.(sn).n=stimuli.hartley(p.trial.display.ptr, 'contrast', p.trial.(sn).contrast, ...
                'ppd', 1, 'M', p.trial.(sn).M);
            p.trial.(sn).n.setup;
            
            if isfield(p.trial.(sn), 'kx')
                return
            end
%             p.trial.(sn).n.update;
            p.trial.(sn).setupRNG=setupRNG;
            
            p.trial.(sn).maxFrames=10e3;
            p.trial.(sn).count=1;
            p.trial.(sn).kx=nan(p.trial.(sn).maxFrames, p.trial.(sn).count);
            p.trial.(sn).ky=nan(p.trial.(sn).maxFrames, p.trial.(sn).count);
            p.trial.(sn).on=zeros(p.trial.(sn).maxFrames,p.trial.(sn).count);
            p.trial.(sn).phi=nan(p.trial.(sn).maxFrames,p.trial.(sn).count);
            p.trial.(sn).tf=nan(p.trial.(sn).maxFrames,p.trial.(sn).count);
            
            % exponential decay
            p.trial.(sn).M=p.trial.display.ppd; % grid size
%             sort([-2.^(0:P.nOctaves)*P.Freq0 0 2.^(0:P.nOctaves)*P.Freq0]); % both positive and negative sied
            p.trial.(sn).kxs=sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);
            p.trial.(sn).kys=sort([-2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0 0 2.^(0:(p.trial.(sn).nOctaves-1))*p.trial.(sn).Freq0]);
            
        
            on=ceil(exprnd(p.trial.(sn).OnDuration, p.trial.(sn).maxFrames,1));
            off=round(exprnd(p.trial.(sn).OffDuration, p.trial.(sn).maxFrames,1));
            on=min(on, p.trial.(sn).MaxDuration);
            off=min(off, p.trial.(sn).MaxDuration);
            step=on+off;
            nUpdates=find(cumsum(step)>p.trial.(sn).maxFrames,1);
            
            [kxg, kyg, ktfg]=ndgrid(p.trial.(sn).kxs, p.trial.(sn).kys, p.trial.(sn).tfs);
            gridIx=randi(p.trial.(sn).setupRNG, numel(kxg), nUpdates, 1);
            fr=0;
            for iStim=1:nUpdates
                iFrames=fr+(1:on(iStim));
                p.trial.(sn).kx(iFrames)=kxg(gridIx(iStim));
                p.trial.(sn).ky(iFrames)=kyg(gridIx(iStim));
                p.trial.(sn).on(iFrames)=1;
                p.trial.(sn).tf(iFrames)=ktfg(gridIx(iStim));
                p.trial.(sn).phi(iFrames)=rand*2*pi;
                fr=iFrames(end)+off(iStim)-1;
            end
            
%             step=p.trial.(sn).OnDuration+p.trial.(sn).OffDuration;
%             nUpdates=ceil(p.trial.(sn).maxFrames/step);
%             [kxg, kyg, ktfg]=ndgrid(p.trial.(sn).kxs, p.trial.(sn).kys, p.trial.(sn).tfs);
%             gridIx=randi(p.trial.(sn).setupRNG, numel(kxg), nUpdates, 1);
%             
%             for iStim=1:nUpdates
%                 iFrames=(iStim-1)*step + (1:p.trial.(sn).OnDuration);
%                 p.trial.(sn).kx(iFrames)=kxg(gridIx(iStim));
%                 p.trial.(sn).ky(iFrames)=kyg(gridIx(iStim));
%                 p.trial.(sn).on(iFrames)=1;
%                 p.trial.(sn).tf(iFrames)=ktfg(gridIx(iStim));
%                 p.trial.(sn).phi(iFrames)=nan;
%             end
%             p.trial.(sn).scale=nan(10e3, p.trial.(sn).n.count);
%             p.trial.(sn).contrast=nan(10e3, p.trial.(sn).n.count);
%         end
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'OnDuration')
            p.trial.(sn).OnDuration=2;
        end
        
        if ~isfield(p.trial.(sn), 'OffDuration')
            p.trial.(sn).OffDuration=2;
        end
        
        if ~isfield(p.trial.(sn), 'MaxDuration')
            p.trial.(sn).MaxDuration=20;
        end
        
        if ~isfield(p.trial.(sn), 'contrast')
            p.trial.(sn).contrast=.2;
        end
        
        
        if ~isfield(p.trial.(sn), 'tfs')
            p.trial.(sn).tfs=0; %[0 2 4 8 16];
        end
        
        if ~isfield(p.trial.(sn), 'sfscale')
            p.trial.(sn).sfscale=1;
        end
        
        if ~isfield(p.trial.(sn), 'nOctaves')
            p.trial.(sn).nOctaves=5; % grid size
        end
        
        if ~isfield(p.trial.(sn), 'Freq0')
            p.trial.(sn).Freq0=.1; % grid size
        end
        
        
        p.trial.(sn).M=p.trial.display.ppd; % grid size
        p.trial.(sn).kxs=sort([0 2.^(0:p.trial.(sn).nOctaves)*p.trial.(sn).Freq0]);
        p.trial.(sn).kys=sort([0 2.^(0:p.trial.(sn).nOctaves)*p.trial.(sn).Freq0]);
        
        
        p.trial.(sn).count=1;
        [p.trial.(sn).kxgrid, p.trial.(sn).kygrid]=meshgrid(p.trial.(sn).kxs, p.trial.(sn).kys);
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
%         if p.trial.(sn).on
            ix=p.trial.iFrame:size(p.trial.(sn).kx,1);
            p.trial.(sn).kx(ix,:)=[];
            p.trial.(sn).ky(ix,:)=[];
            p.trial.(sn).on(ix,:)=[];
            p.trial.(sn).tf(ix,:)=[];
            p.trial.(sn).phi(ix,:)=[];
%             p.trial.(sn).scale(ix,:)=[];
%         end
        
end