function p=gaussPyrNoise(p, state, sn)
% gaussPyrNoise is a module for PLDAPS open reception
% Displays images found in a specified directory in the background of a
% task

if nargin<3
    sn='gaussPyrNoise';
end


switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).noise.afterFrame();
        
    case p.trial.pldaps.trialStates.frameDraw
        
        %------------------------------------------------------------------
        % Draw Background
%         Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).tex(p.trial.(sn).texToDraw), [], [0 0 p.trial.display.pWidth p.trial.display.pHeight], [], [], [], [], [], kPsychDontDoRotation)
        p.trial.(sn).noise.beforeFrame();
        
    case p.trial.pldaps.trialStates.trialSetup
        
        %------------------------------------------------------------------
        % Select images to draw this trial
        n = stimuli.gaussians(p, 'sigma', [0.1 .25 .5 1]);
        p.trial.(sn).noise = stimuli.textureFlashNoise(p, n, 'num', 200);
        p.trial.(sn).noise.texObj.alpha = .1;
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
       p.trial.(sn).noise.texObj.closeAll();
       
       
       try
       figure(100); clf
       plot(p.data{end}.timing.frameStateChangeTimes'*1000, '-')
       drawnow
       end
       
       
end