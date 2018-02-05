function p=DotApertureMapping(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='MotionMapping';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
        defaultArgs = {...
            'onDuration',           'duration stimulus is on (in frames)', ...
            'offDuration',          'duration between stimulus presentations (in frames)', ...
            'numDirections',        'number of directions (evenly spaced between 0 and 360)', ...
            'nDotApertures',        'number of dot apertures to show', ...
            'dotSpeeds',            'dot speeds (deg/sec)', ...
            'randomizeDirection',   'directions in random order (opposed to in sequence)', ...
            'gazeContingent',       'position is relative to current eye position if true', ...
            'dotx',                 'x position (relative to screen center or eye position depending on gazeContingent flag)', ...
            'doty',                 'y position (relative to screen center or eye position depending on gazeContingent flag)', ...
            'apertureSize',         'dot aperture size (radius, degrees)', ...
            'dotContrast',          'gray scale of dots (0 = mean gray; -.5 = black; .5 = white)', ...
            'minDuration',          'what is this', ...
            'maxDuration',          'what is this', ...
            'minFixation',          'time fixation has been held before showing stimulus (default: no fixation)', ...
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
            'onDuration',           2, ...          % duration stimulus is on (in frames)
            'offDuration',          2, ...          % duration between stimulus presentations (in frames)
            'numDirections',        12, ...         % number of directions (evenly spaced between 0 and 360)
            'nDotApertures',        8, ...          % number of dot apertures to show
            'dotSpeeds',            [10 15], ...    % speeds (deg/sec)
            'randomizeDirection',   true, ...       % directions in random order (opposed to in sequence)
            'gazeContingent',       false, ...      % position is relative to current eye position if true
            'dotx',                 0, ...          % x position (relative to screen center or eye position depending on gazeContingent flag)
            'doty',                 0, ...          % y position (relative to screen center or eye position depending on gazeContingent flag)
            'apertureSize',         2, ...          % dot aperture size (radius, degrees)
            'dotContrast',          -.2, ...        % gray scale of dots (0 = mean gray; -.5 = black; .5 = white)
            'minDuration',          8, ...          % what is this
            'maxDuration',          20, ...         % what is this
            'minFixation',          nan, ...        % time fixation has been held before showing stimulus (default: no fixation)
            };
        
        % step through argument pairs and add them to the module
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end

    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        for kDots = 1:p.trial.(sn).nDotApertures
            
            p.trial.(sn).hDots(kDots)               = stimuli.dotsUniform(p.trial.display.ptr);
            p.trial.(sn).hDots(kDots).dotSpeed      = 0;
            p.trial.(sn).hDots(kDots).dotSize       = .1 * p.trial.display.ppd;
            p.trial.(sn).hDots(kDots).dotDirection  = 0;
            p.trial.(sn).hDots(kDots).radius        = p.trial.(sn).apertureSize*p.trial.display.ppd;
            p.trial.(sn).hDots(kDots).dotLifetime   = inf;
            p.trial.(sn).hDots(kDots).mode          = 0;
            p.trial.(sn).hDots(kDots).dist          = 0;
            p.trial.(sn).hDots(kDots).range         = 0;
            
            x = rand(setupRNG)*p.trial.display.pWidth - p.trial.display.ctr(1);
            y = rand(setupRNG)*p.trial.display.pHeight - p.trial.display.ctr(2);
            
            p.trial.(sn).hDots(kDots).position = [x y];
            p.trial.(sn).hDots(kDots).dotColor = repmat(p.trial.(sn).dotContrast, 1, 3);
            p.trial.(sn).hDots(kDots).numDots  = ceil(4*pi*p.trial.(sn).apertureSize^2);
            
            p.trial.(sn).hDots(kDots).trialSetup();
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
                p.trial.(sn).direction(iFrames, kDots) = (randi(setupRNG,n)-1)*(360/n);
                p.trial.(sn).speed(iFrames, kDots)  = p.trial.(sn).dotSpeeds(randi(setupRNG, nSpeeds)) * p.trial.display.ppd / p.trial.display.frate;
                fr=iFrames(end)+off(iStim)-1;
            end
        end

    %--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw    
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        for kDots = 1:p.trial.(sn).nDotApertures
            p.trial.(sn).hDots(kDots).direction = p.trial.(sn).direction(p.trial.iFrame,kDots);
            p.trial.(sn).hDots(kDots).speed     = p.trial.(sn).speed(p.trial.iFrame,kDots);
            dx = p.trial.(sn).hDots(kDots).speed * cosd(p.trial.(sn).hDots(kDots).direction);
            dy = p.trial.(sn).hDots(kDots).speed * sind(p.trial.(sn).hDots(kDots).direction);
            
            p.trial.(sn).hDots(kDots).dx(1:end) = dx;
            p.trial.(sn).hDots(kDots).dy(1:end) = dy;
            
            p.trial.(sn).hDots(kDots).frameUpdate(p);
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
                p.trial.(sn).hDots(kDots).frameDraw(p);
            else
                p.trial.(sn).on(p.trial.iFrame, kDots) = 0;
            end
        end
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
%         if p.trial.(sn).on
%             ix=p.trial.iFrame:size(p.trial.(sn).x,1);
            p.trial.(sn).x = p.trial.(sn).x(1:p.trial.iFrame,:);
            p.trial.(sn).y = p.trial.(sn).y(1:p.trial.iFrame,:);
            p.trial.(sn).direction = p.trial.(sn).direction; %(1:p.trial.iFrame,:);
            p.trial.(sn).speed = p.trial.(sn).speed; %(1:p.trial.iFrame,:);
            p.trial.(sn).size=p.trial.(sn).size; %(1:p.trial.iFrame,:);
%             p.trial.(sn).scale(ix,:)=[];
%         end
%             trialStart = numel(p.data)+1;
%             if isempty(trialStart)
%                 trialStart = 1;
%             end
%          for i = trialStart:p.trial.pldaps.finish
%              p.conditions{i}.(sn).dotx = p.trial.(sn).dotx;
%              p.conditions{i}.(sn).doty = p.trial.(sn).doty;
%              p.conditions{i}.(sn).apertureSize = p.trial.(sn).hDots.maxRadius/p.trial.display.ppd;
%              p.conditions{i}.(sn).gazeContingent =  p.trial.(sn).gazeContingent;
%              p.conditions{i}.(sn).handMap        =  p.trial.(sn).handMap;
%              p.conditions{i}.(sn).speed          =  p.trial.(sn).hDots.speed*p.trial.display.frate/p.trial.display.ppd;
%          end
        
end