function p=DotMotionMapping(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='MotionMapping';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        
    case p.trial.pldaps.trialStates.frameUpdate
        
        p.trial.(sn).hDots.afterFrame();
        
        % Update direction
        if mod(p.trial.iFrame, p.trial.(sn).duration)==0
            if p.trial.(sn).randomizeDirection
                p.trial.(sn).hDots.direction = (randi(p.trial.(sn).numDirections)-1)*(360)/p.trial.(sn).numDirections;
            else
                p.trial.(sn).hDots.direction = p.trial.(sn).hDots.direction + (360)/p.trial.(sn).numDirections;
            end
            p.trial.(sn).hDots.initDots(1:p.trial.(sn).hDots.numDots); % all dots!
        end
        
        p.trial.(sn).x(p.trial.iFrame) = p.trial.(sn).hDots.position(1);
        p.trial.(sn).y(p.trial.iFrame) = p.trial.(sn).hDots.position(2);
        p.trial.(sn).direction(p.trial.iFrame) =  p.trial.(sn).hDots.direction;
        
        p.trial.(sn).speed(p.trial.iFrame) = p.trial.(sn).hDots.speed;
        p.trial.(sn).size(p.trial.iFrame) = p.trial.(sn).hDots.maxRadius;
        
        % Keyboard Checking
        if any(p.trial.keyboard.firstPressQ)
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Rarrow)
                p.trial.(sn).dotx=p.trial.(sn).dotx+100;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Larrow)
                p.trial.(sn).dotx=p.trial.(sn).dotx-100;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Uarrow)
                p.trial.(sn).doty=p.trial.(sn).doty-100;
            end
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Darrow)
                p.trial.(sn).doty=p.trial.(sn).doty+100;
            end
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).hDots.position = [p.trial.eyeX+p.trial.(sn).dotx p.trial.eyeY+p.trial.(sn).doty];
        p.trial.(sn).hDots.beforeFrame();
        
        
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        p.trial.(sn).hDots = stimuli.dots(p.trial.display.ptr);
        p.trial.(sn).hDots.speed = p.trial.(sn).speed * p.trial.display.ppd / p.trial.display.frate;
        p.trial.(sn).hDots.size  = .1 * p.trial.display.ppd;
        p.trial.(sn).hDots.direction = 0;
        p.trial.(sn).hDots.maxRadius = p.trial.(sn).apertureSize*p.trial.display.ppd;
        p.trial.(sn).hDots.lifetime = inf;
        p.trial.(sn).hDots.mode = 0;
        p.trial.(sn).hDots.dist = 0;
        p.trial.(sn).hDots.bandwdth = 0;
        p.trial.(sn).hDots.coherence = 1;
        p.trial.(sn).hDots.position = [0 0];
        p.trial.(sn).hDots.colour = repmat(-.5, 1, 3);
        p.trial.(sn).hDots.numDots = ceil(2*pi*p.trial.(sn).apertureSize^2);
        
        p.trial.(sn).hDots.beforeTrial();
        
        nFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).x = nan(nFrames,1);
        p.trial.(sn).y = nan(nFrames,1);
        p.trial.(sn).direction = nan(nFrames,1);
        p.trial.(sn).speed = nan(nFrames,1);
        p.trial.(sn).size = nan(nFrames,1);
        
       
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'duration')
            p.trial.(sn).duration=10;
        end
        
        if ~isfield(p.trial.(sn), 'numDirections')
            p.trial.(sn).numDirections=12;
        end
        
        if ~isfield(p.trial.(sn), 'speed')
            p.trial.(sn).speed=20;
        end
        
        if ~isfield(p.trial.(sn), 'randomizeDirection')
            p.trial.(sn).randomizeDirection=false;
        end
        
        if ~isfield(p.trial.(sn), 'dotx')
            p.trial.(sn).dotx = 0;
        end
        
        if ~isfield(p.trial.(sn), 'doty')
            p.trial.(sn).doty = 0;
        end
        
        if ~isfield(p.trial.(sn), 'apertureSize')
            p.trial.(sn).apertureSize = 5;
        end
        
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
%         if p.trial.(sn).on
            ix=p.trial.iFrame:size(p.trial.(sn).x,1);
            p.trial.(sn).x(ix,:)=[];
            p.trial.(sn).y(ix,:)=[];
            p.trial.(sn).direction(ix,:)=[];
            p.trial.(sn).speed(ix,:)=[];
            p.trial.(sn).size(ix,:)=[];
%             p.trial.(sn).scale(ix,:)=[];
%         end
            trialStart = numel(p.data)+1;
            if isempty(trialStart)
                trialStart = 1;
            end
         for i = trialStart:p.trial.pldaps.finish
             p.conditions{i}.(sn).dotx = p.trial.(sn).dotx;
             p.conditions{i}.(sn).doty = p.trial.(sn).doty;
         end
        
end