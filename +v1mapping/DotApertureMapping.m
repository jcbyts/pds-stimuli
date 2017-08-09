function p=DotApertureMapping(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='MotionMapping';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        
    case p.trial.pldaps.trialStates.frameUpdate
        
        for kDots = 1:p.trial.(sn).nDotApertures
            p.trial.(sn).hDots(kDots).direction = p.trial.(sn).direction(p.trial.iFrame,kDots);
            p.trial.(sn).hDots(kDots).speed     = p.trial.(sn).speed(p.trial.iFrame,kDots);
            dx = p.trial.(sn).hDots(kDots).speed * cosd(p.trial.(sn).hDots(kDots).direction);
            dy = p.trial.(sn).hDots(kDots).speed * sind(p.trial.(sn).hDots(kDots).direction);
            
            p.trial.(sn).hDots(kDots).dx(1:end) = dx;
            p.trial.(sn).hDots(kDots).dy(1:end) = dy;
            
            p.trial.(sn).hDots(kDots).afterFrame();
        end
        
        if isfield(p.trial.stimulus, 'm')
            dstep = 360/p.trial.(sn).numDirections;
            p.trial.stimulus.m.direction = round((p.trial.stimulus.m.direction/dstep)) * dstep;
        end
        
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        
        
        for kDots = 1:p.trial.(sn).nDotApertures
            p.trial.(sn).hDots(kDots).position = [p.trial.(sn).x(p.trial.iFrame, kDots) p.trial.(sn).y(p.trial.iFrame, kDots)];
%             p.trial.(sn).hDots(kDots).position = [p.trial.eyeX+p.trial.(sn).x(p.trial.iFrame, kDots) p.trial.eyeY+p.trial.(sn).y(p.trial.iFrame, kDots)];
        
            if p.trial.(sn).on(p.trial.iFrame, kDots) && ~any(p.trial.(sn).hDots(kDots).position<0) && ~any(p.trial.(sn).hDots(kDots).position>1580)
                p.trial.(sn).hDots(kDots).beforeFrame();
%                 x = p.trial.(sn).hDots(kDots).x + p.trial.(sn).hDots(kDots).position(1);
%                 if any(~isreal(x))
%                     keyboard
%                 end
            else
                p.trial.(sn).on(p.trial.iFrame, kDots) = 0;
            end
        end
        
        
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        for kDots = 1:p.trial.(sn).nDotApertures
            
            p.trial.(sn).hDots(kDots) = stimuli.dots(p.trial.display.ptr);
            p.trial.(sn).hDots(kDots).speed = 0;
            p.trial.(sn).hDots(kDots).size  = .1 * p.trial.display.ppd;
            p.trial.(sn).hDots(kDots).direction = 0;
            p.trial.(sn).hDots(kDots).maxRadius = p.trial.(sn).apertureSize*p.trial.display.ppd;
            p.trial.(sn).hDots(kDots).lifetime = inf;
            p.trial.(sn).hDots(kDots).mode = 0;
            p.trial.(sn).hDots(kDots).dist = 0;
            p.trial.(sn).hDots(kDots).bandwdth = 0;
            p.trial.(sn).hDots(kDots).coherence = 1;
            
            x = rand()*p.trial.display.pWidth - p.trial.display.ctr(1);
            y = rand()*p.trial.display.pHeight - p.trial.display.ctr(2);
            
            p.trial.(sn).hDots(kDots).position = [x y];
            p.trial.(sn).hDots(kDots).colour  = repmat(p.trial.(sn).dotContrast, 1, 3);
            p.trial.(sn).hDots(kDots).numDots = ceil(4*pi*p.trial.(sn).apertureSize^2);
            
            p.trial.(sn).hDots(kDots).beforeTrial();
        end
        

        nFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).x          = zeros(nFrames,p.trial.(sn).nDotApertures);
        p.trial.(sn).y          = zeros(nFrames,p.trial.(sn).nDotApertures);
        p.trial.(sn).on         = zeros(nFrames,p.trial.(sn).nDotApertures);
        p.trial.(sn).direction  = zeros(nFrames,p.trial.(sn).nDotApertures);
        p.trial.(sn).speed      = zeros(nFrames,p.trial.(sn).nDotApertures);
        p.trial.(sn).size       = zeros(nFrames,p.trial.(sn).nDotApertures);
        
        
        % --- build noise sequence
        on  = ceil(exprnd(p.trial.(sn).onDuration, nFrames,p.trial.(sn).nDotApertures));
        off = round(exprnd(p.trial.(sn).offDuration, nFrames,p.trial.(sn).nDotApertures));

        on  = max(on, p.trial.(sn).minDuration);
        off = max(off, p.trial.(sn).minDuration);
        
        on  = min(on, p.trial.(sn).MaxDuration);
        off = min(off, p.trial.(sn).MaxDuration);
        
        step=on+off;
        
        % make them out of phase
        
        on(1,:) = (1:p.trial.(sn).nDotApertures)*3;
        n = p.trial.(sn).numDirections;
        nSpeeds = numel(p.trial.(sn).dotSpeeds);
        pWidth  = p.trial.display.pWidth;
        pHeight = p.trial.display.pHeight;
        
        for kDots = 1:p.trial.(sn).nDotApertures
            nUpdates=find(cumsum(step(:,kDots))>nFrames,1);
        
            fr=0;
            for iStim=1:nUpdates
                iFrames=fr+(1:on(iStim));
                p.trial.(sn).x(iFrames, kDots)  =   rand*pWidth;
                p.trial.(sn).y(iFrames, kDots)  =   rand*pHeight;
                p.trial.(sn).on(iFrames, kDots) =  1;
                p.trial.(sn).direction(iFrames, kDots) = (randi(n)-1)*(360/n);
                p.trial.(sn).speed(iFrames, kDots)  = p.trial.(sn).dotSpeeds(randi(nSpeeds)) * p.trial.display.ppd / p.trial.display.frate;
                fr=iFrames(end)+off(iStim)-1;
            end
        end
        
       
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'onDuration')
            p.trial.(sn).onDuration = 2;
        end
        
        if ~isfield(p.trial.(sn), 'offDuration')
            p.trial.(sn).offDuration = 2;
        end
        
        if ~isfield(p.trial.(sn), 'numDirections')
            p.trial.(sn).numDirections=12;
        end
        
        if ~isfield(p.trial.(sn), 'nDotApertures')
            p.trial.(sn).nDotApertures=8;
        end
        
        
        if ~isfield(p.trial.(sn), 'dotSpeeds')
            p.trial.(sn).dotSpeeds = [10 15 20];
        end
        
        if ~isfield(p.trial.(sn), 'randomizeDirection')
            p.trial.(sn).randomizeDirection=false;
        end
        
        if ~isfield(p.trial.(sn), 'gazeContingent')
            p.trial.(sn).gazeContingent=false;
        end
        
        if ~isfield(p.trial.(sn), 'dotx')
            p.trial.(sn).dotx = 0;
        end
        
        if ~isfield(p.trial.(sn), 'doty')
            p.trial.(sn).doty = 0;
        end
        
        if ~isfield(p.trial.(sn), 'apertureSize')
            p.trial.(sn).apertureSize = 2;
        end
        
        if ~isfield(p.trial.(sn), 'dotContrast')
            p.trial.(sn).dotContrast = -.2;
        end
        
        if ~isfield(p.trial.(sn), 'maxFrames')
            p.trial.(sn).maxFrames = 10e3;
        end
        
        if ~isfield(p.trial.(sn), 'MaxDuration')
            p.trial.(sn).MaxDuration = 20;
        end
        
        if ~isfield(p.trial.(sn), 'minDuration')
            p.trial.(sn).minDuration = 8;
        end
       
        
        
        
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
%         if p.trial.(sn).on
%             ix=p.trial.iFrame:size(p.trial.(sn).x,1);
            p.trial.(sn).x = p.trial.(sn).x; %(1:p.trial.iFrame,:);
            p.trial.(sn).y = p.trial.(sn).y; %(1:p.trial.iFrame,:);
            p.trial.(sn).direction = p.trial.(sn).direction; %(1:p.trial.iFrame,:);
            p.trial.(sn).speed = p.trial.(sn).speed; %(1:p.trial.iFrame,:);
            p.trial.(sn).size=p.trial.(sn).size; %(1:p.trial.iFrame,:);
%             p.trial.(sn).scale(ix,:)=[];
%         end
            trialStart = numel(p.data)+1;
            if isempty(trialStart)
                trialStart = 1;
            end
%          for i = trialStart:p.trial.pldaps.finish
%              p.conditions{i}.(sn).dotx = p.trial.(sn).dotx;
%              p.conditions{i}.(sn).doty = p.trial.(sn).doty;
%              p.conditions{i}.(sn).apertureSize = p.trial.(sn).hDots.maxRadius/p.trial.display.ppd;
%              p.conditions{i}.(sn).gazeContingent =  p.trial.(sn).gazeContingent;
%              p.conditions{i}.(sn).handMap        =  p.trial.(sn).handMap;
%              p.conditions{i}.(sn).speed          =  p.trial.(sn).hDots.speed*p.trial.display.frate/p.trial.display.ppd;
%          end
        
end