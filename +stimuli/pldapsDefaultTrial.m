function p=pldapsDefaultTrial(p,state)
% Default trial function just measures input
if nargin==1 %initial call to setup conditions
    
    % ---------------------------------------------------------------------
    % --- Colors
    % PLDAPS uses a color lookup table (CLUT) to draw separate colors to 
    % the two screens: subject screen and experimenter screen
    % These colors are set here in defaultColors and stimuli.clutColors.
    % You can create more colors by following the formula within.
    %
    % When drawing to the overlay (for two seperate colors), the draw call
    % will use a color that is an index value into the CLUT that is setup
    % here.
    p = defaultColors(p);
    stimuli.clutColors(p);
    
    % dot sizes for drawing
    p.defaultParameters.stimulus.eyeW      = 8;    % eye indicator width in pixels
    p.defaultParameters.stimulus.cursorW   = 8;    % cursor width in pixels
    
    p.defaultParameters.pldaps.trialMasterFunction = 'runModularTrial';
    p.defaultParameters.pldaps.trialFunction = 'stimuli.pldapsDefaultTrial';
    
    % seconds per trial
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
            
        case p.trial.pldaps.trialStates.trialItiDraw
            
            % Flip a blank screen
            Screen('FillRect', p.trial.display.overlayptr, p.trial.display.bgColor);
            Screen('Flip', p.trial.display.ptr);
            
    end
end