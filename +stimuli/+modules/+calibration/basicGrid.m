function p = basicGrid(p, state, sn)
% BASIC GRID: draw a grid of points

if nargin<3
    sn='calibration';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
    defaultArgs = {...
            'onDuration',               'frames flash is on', ...
            'offDuration',              'frames flash is off', ...
            };
    fprintf('No arguments passed in: call from within pldaps\n')
    fprintf('<strong>Optional Parameters:</strong>\n')
    fprintf('<strong>%s</strong>\t\t\t%s\n', defaultArgs{:})
    return
end

switch state
    
    % copy-paste this in every module that has the default trial states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        stimuli.setupDefaultFrameStates(p, sn);
        stimuli.setupRandomSeed(p, sn);
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
        % --- set up default parameters
        defaultArgs = {...
            'onDuration',               60, ...
            'offDuration',              100, ...
            'shrinkTimeConstant',       .5, ...
            'onRate',                   .1, ...
            };
        
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        [xx, yy] = meshgrid([-5 -2 0 2 5]);
        
        p.trial.(sn).posXY = [xx(:) yy(:)];
        
        p.trial.(sn).numTargs = size(p.trial.(sn).posXY,1);
        
        ppd = p.trial.display.ppd;
        ctr = p.trial.display.ctr(1:2);
        
        for i = 1:p.trial.(sn).numTargs
            p.trial.(sn).hTarg(i) = stimuli.objects.fixation();
            p.trial.(sn).hTarg(i).position = p.trial.(sn).posXY(i,:)*ppd + ctr;
            p.trial.(sn).hTarg(i).shrinkTimeConstant = p.trial.(sn).shrinkTimeConstant;
            p.trial.(sn).hTarg(i).wincolor = p.trial.display.clut.bg_white;
            p.trial.(sn).hTarg(i).color    = p.trial.display.clut.black;
            p.trial.(sn).hTarg(i).ctrColor = p.trial.display.clut.bg;
            rnd = rand(p.trial.(sn).hTarg(i).rng);
            p.trial.(sn).hTarg(i).stimValue = rnd < p.trial.(sn).onRate;
            p.trial.(sn).hTarg(i).radius = .2 * ppd;
            p.trial.(sn).hTarg(i).maxRadius = 5 * ppd;
        end
        
        maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).targOn = zeros(p.trial.(sn).numTargs, maxFrames);
                
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        for i = 1:p.trial.(sn).numTargs
            p.trial.(sn).hTarg(i).frameUpdate(p);
            if p.trial.(sn).hTarg(i).isFixated
                p = pds.behavior.reward.give(p);
                p.trial.(sn).hTarg(i).stimValue = 0;
            end
            
            if p.trial.(sn).hTarg(i).stimValue == 0
                rnd = rand(p.trial.(sn).hTarg(i).rng);
                p.trial.(sn).hTarg(i).stimValue = rnd < p.trial.(sn).onRate;
            end
        end
        
%         if p.trial.iFrame > 1 && all(p.trial.(sn).targOn(:,p.trial.iFrame-1)==0)
%             p.trial.flagNextTrial = true;
%         end
            
        
    case p.trial.pldaps.trialStates.frameDraw
        
        for i = 1:p.trial.(sn).numTargs
            p.trial.(sn).hTarg(i).frameDraw(p); % draw the flash
            p.trial.(sn).targOn(i, p.trial.iFrame) = p.trial.(sn).hTarg(i).stimValue;
        end
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        % don't need to do anything because our stimulus logs itself
        
        % turn off the flash
        p.trial.(sn).hFlash.stimValue = false;
        
end