function p=DotMotionMapping(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='MotionMapping';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
    case p.trial.pldaps.trialStates.frameUpdate
        
        
        p.trial.(sn).hDots.afterFrame();
        
        if isfield(p.trial.stimulus, 'm')
            dstep = 360/p.trial.(sn).numDirections;
            p.trial.stimulus.m.direction = round((p.trial.stimulus.m.direction/dstep)) * dstep;
        end
        
        on = false; 
        
        % Update direction
        
        if p.trial.(sn).handMap && p.trial.iFrame > 1
            
            mxy = p.trial.mouse.cursorSamples(:,p.trial.iFrame-1); % - p.trial.display.ctr(1:2)';
            
            dx = mxy(1) - p.trial.(sn).hDots.position(1);
            dy = mxy(2) - p.trial.(sn).hDots.position(2);
            dx = dx/p.trial.display.frate*3;
            dy = -dy/p.trial.display.frate*3; %
            [th, rho] = cart2pol(dx, dy);
            p.trial.(sn).hDots.direction = th/pi*180;
            p.trial.(sn).hDots.speed = rho;
            p.trial.(sn).hDots.dx(1:end) = dx;
            p.trial.(sn).hDots.dy(1:end) = dy;
            
            
            
        else
            
            if mod(p.trial.onCtr, p.trial.(sn).onDuration)==0
                on = false;
                p.trial.offCtr = p.trial.offCtr + 1;
                p.trial.onCtr  = 0;
            end
            
            if mod(p.trial.offCtr, p.trial.(sn).offDuration)==0 || p.trial.(sn).offDuration==0
                on = true;
                p.trial.offCtr = 0;
                p.trial.onCtr  = p.trial.onCtr + 1;
            end
            
            if p.trial.onCtr==1
              if (p.trial.(sn).numDirections > 1)
                    
                if p.trial.(sn).randomizeDirection
                    p.trial.(sn).hDots.direction = p.trial.(sn).directionPrior.drawfromprior;
%                     p.trial.(sn).hDots.direction = (randi(p.trial.(sn).numDirections)-1)*(360)/p.trial.(sn).numDirections;
                else
                    p.trial.(sn).hDots.direction = p.trial.(sn).hDots.direction + (360)/p.trial.(sn).numDirections;
                end
                %             p.trial.(sn).hDots.initDots(1:p.trial.(sn).hDots.numDots); % all dots!
                dx = p.trial.(sn).hDots.speed * cosd(p.trial.(sn).hDots.direction);
                dy = p.trial.(sn).hDots.speed * sind(p.trial.(sn).hDots.direction);
                p.trial.(sn).hDots.dx(1:end) = dx;
                p.trial.(sn).hDots.dy(1:end) = dy;
%                 disp(p.trial.(sn).hDots.direction)
              end
            end
        end
        
        p.trial.(sn).x(p.trial.iFrame) = p.trial.(sn).hDots.position(1);
        p.trial.(sn).y(p.trial.iFrame) = p.trial.(sn).hDots.position(2);
        p.trial.(sn).direction(p.trial.iFrame) =  p.trial.(sn).hDots.direction;
        p.trial.(sn).on(p.trial.iFrame) = on;
        p.trial.(sn).speed(p.trial.iFrame) = p.trial.(sn).hDots.speed;
        p.trial.(sn).size(p.trial.iFrame)  = p.trial.(sn).hDots.maxRadius;
        
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
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.plusKey)
                p.trial.(sn).hDots.maxRadius=p.trial.(sn).hDots.maxRadius+50;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.minusKey)
                p.trial.(sn).hDots.maxRadius= max(p.trial.(sn).hDots.maxRadius-50, 10);
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.rKey)
                % p.trial.(sn).randomizeDirection = ~p.trial.(sn).randomizeDirection;
                p.trial.(sn).hDots.direction = p.trial.(sn).hDots.direction + ...
                                               (360/12);
                dx = p.trial.(sn).hDots.speed * cosd(p.trial.(sn).hDots.direction);
                dy = p.trial.(sn).hDots.speed * sind(p.trial.(sn).hDots.direction);
                p.trial.(sn).hDots.dx(1:end) = dx;
                p.trial.(sn).hDots.dy(1:end) = dy;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.hKey)
                % p.trial.(sn).handMap = ~p.trial.(sn).handMap;
                p.trial.(sn).hDots.direction = p.trial.(sn).hDots.direction - ...
                                               (360/12);
                dx = p.trial.(sn).hDots.speed * cosd(p.trial.(sn).hDots.direction);
                dy = p.trial.(sn).hDots.speed * sind(p.trial.(sn).hDots.direction);
                p.trial.(sn).hDots.dx(1:end) = dx;
                p.trial.(sn).hDots.dy(1:end) = dy;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.gKey)
                p.trial.(sn).gazeContingent = ~p.trial.(sn).gazeContingent;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.zerKey)
                
            
                p.trial.(sn).hDots.dx = p.trial.(sn).hDots.dx*(3/2);
                p.trial.(sn).hDots.dy = p.trial.(sn).hDots.dy*(3/2);
                [~, rho] = cart2pol(p.trial.(sn).hDots.dx, p.trial.(sn).hDots.dy);
                p.trial.(sn).hDots.speed = mean(rho);
            
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.ninKey)
                p.trial.(sn).hDots.dx = p.trial.(sn).hDots.dx*(2/3);
                p.trial.(sn).hDots.dy = p.trial.(sn).hDots.dy*(2/3);
                [~, rho] = cart2pol(p.trial.(sn).hDots.dx, p.trial.(sn).hDots.dy);
                p.trial.(sn).hDots.speed = mean(rho);
            end
        end
        
        if p.trial.(sn).gazeContingent
            p.trial.(sn).hDots.position = [p.trial.eyeX+p.trial.(sn).dotx p.trial.eyeY+p.trial.(sn).doty];
        else
            p.trial.(sn).hDots.position = [p.trial.display.ctr(1)+p.trial.(sn).dotx p.trial.display.ctr(2)+p.trial.(sn).doty];
        end
        
        if p.trial.(sn).on(p.trial.iFrame)
            p.trial.(sn).hDots.beforeFrame();
        end
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        
        
        
        
        
    case p.trial.pldaps.trialStates.trialSetup
        
%         p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        p.trial.(sn).hDots = stimuli.dots(p.trial.display.ptr);
        p.trial.(sn).speed = randsample(p.trial.(sn).dotSpeeds, 1);
        p.trial.(sn).hDots.speed = p.trial.(sn).speed * p.trial.display.ppd / p.trial.display.frate;
        p.trial.(sn).hDots.size  = .3 * p.trial.display.ppd;
        
        p.trial.(sn).directionPrior = directionprior(p.trial.(sn).numDirections, 'unimodal', p.trial.(sn).priorMu, p.trial.(sn).priorKappa);
        
        if (p.trial.(sn).numDirections > 1)
%             p.trial.(sn).hDots.direction = 0;
            p.trial.(sn).hDots.direction = p.trial.(sn).directionPrior.drawfromprior;
        else
            p.trial.(sn).hDots.direction = p.trial.(sn).direction;
            p.trial.(sn).direction
            disp('check new trial')
        end
        
        p.trial.(sn).hDots.maxRadius = p.trial.(sn).apertureSize*p.trial.display.ppd;
        p.trial.(sn).hDots.lifetime = inf;
        p.trial.(sn).hDots.mode = 0;
        p.trial.(sn).hDots.dist = 0;
        p.trial.(sn).hDots.bandwdth = 0;
        p.trial.(sn).hDots.coherence = 1;
        p.trial.(sn).hDots.position = [0 0];
        p.trial.(sn).hDots.colour = repmat(p.trial.(sn).dotContrast, 1, 3);
        p.trial.(sn).hDots.numDots = ceil(.3*pi*p.trial.(sn).apertureSize^2);
        
        p.trial.(sn).hDots.beforeTrial();
        
        nFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).x  = nan(nFrames,1);
        p.trial.(sn).y  = nan(nFrames,1);
        p.trial.(sn).on = false(nFrames,1);
        p.trial.(sn).direction = nan(nFrames,1);
        p.trial.(sn).speed = nan(nFrames,1);
        p.trial.(sn).size  = nan(nFrames,1);
        
%         p.trial.(sn).handMap = false;
        p.trial.offCtr = 1;
        p.trial.onCtr  = 0;
        
        if p.trial.(sn).offDuration==0
            p.trial.offCtr = 0;
            p.trial.onCtr  = 1;
        end
        
       
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'onDuration')
            p.trial.(sn).onDuration = 10;
        end
        
        if ~isfield(p.trial.(sn), 'offDuration')
            p.trial.(sn).offDuration = 10;
        end
        
        if ~isfield(p.trial.(sn), 'numDirections')
            p.trial.(sn).numDirections=12;
        end
        
        if ~isfield(p.trial.(sn), 'dotSpeeds')
            p.trial.(sn).dotSpeeds=20;
        end
        
        if ~isfield(p.trial.(sn), 'direction')
            p.trial.(sn).direction=0;
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
            p.trial.(sn).apertureSize = 5;
        end
        
        if ~isfield(p.trial.(sn), 'dotContrast')
            p.trial.(sn).dotContrast = -.2;
        end
        
        if ~isfield(p.trial.(sn), 'handMap')
            p.trial.(sn).handMap = false;
        end      
        
        if ~isfield(p.trial.(sn), 'priorMu')
           p.trial.(sn).priorMu = 0; 
        end
        
        if ~isfield(p.trial.(sn), 'priorKappa')
           p.trial.(sn).priorKappa = 0; 
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
             p.conditions{i}.(sn).apertureSize = p.trial.(sn).hDots.maxRadius/p.trial.display.ppd;
             p.conditions{i}.(sn).gazeContingent =  p.trial.(sn).gazeContingent;
             p.conditions{i}.(sn).handMap        =  p.trial.(sn).handMap;
             p.conditions{i}.(sn).speed          =  p.trial.(sn).hDots.speed*p.trial.display.frate/p.trial.display.ppd;
             p.conditions{i}.(sn).direction      =  p.trial.(sn).hDots.direction;
         end
        
end