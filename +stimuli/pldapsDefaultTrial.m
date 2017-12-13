function p=pldapsDefaultTrial(p,state)
% Default trial function just measures input
if nargin==1 %initial call to setup conditions
    
    % Colors
    %-------------------------------------------------------------------------%
    p = defaultColors(p);
    
    % dot sizes for drawing
    p.defaultParameters.stimulus.eyeW      = 8;    % eye indicator width in pixels
    p.defaultParameters.stimulus.fixdotW   = 8;    % width of the fixation dot
    p.defaultParameters.stimulus.targdotW  = 8;    % width of the target dot
    p.defaultParameters.stimulus.cursorW   = 8;    % cursor width in pixels
    
    p.defaultParameters.pldaps.trialMasterFunction = 'runModularTrial';
    p.defaultParameters.pldaps.trialFunction = 'stimuli.pldapsDefaultTrial';
    
    % seconds per trial.
    p.trial.pldaps.maxTrialLength = 20;
    p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    
else
    %if you don't want all the pldapsDefaultTrialFucntions states to be used,
    %just call them in the states you want to use it.
    %otherwise just leave it here
    pldapsDefaultTrialFunction(p,state);
    switch state
        
        case p.trial.pldaps.trialStates.frameFlip
            if p.trial.iFrame == p.trial.pldaps.maxFrames
                p.trial.flagNextTrial=true;
            end
    end
end