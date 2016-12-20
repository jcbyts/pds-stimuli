function p=faceForage(p, state, sn)
% FACEFORAGE module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='faceForage';
end

if nargin==1
    Screen('Preference', 'TextRenderer', 1)
    
    p = pdsDefaultTrialStructure(p);
    
%     p.defaultParameters.pldaps.trialMasterFunction='runModularTrial';
    p.defaultParameters.pldaps.trialFunction='faceForage';
    
    p.trial.pldaps.maxTrialLength = 5;
    p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    
    c.Nr=1; %one condition;
    p.conditions=repmat({c},1,200);
    
    p.defaultParameters.pldaps.finish = length(p.conditions);
    
    p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
    p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
    p.trial.exploded=0;
    
    return
end



pldapsDefaultTrialFunction(p,state);
switch state
    
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        arrayfun(@(x) x.move, p.trial.(sn).m)
        
    case p.trial.pldaps.trialStates.frameDraw
        
        arrayfun(@(x) x.draw, p.trial.(sn).m)
        Screen('DrawText', p.trial.display.ptr, num2str(p.trial.exploded), 50, 50, [1 1 1]);
%         DrawFormattedText(p.trial.display.overlayptr, num2str(p.trial.exploded), 50, 50,  p.trial.display.clut.redbg);
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        %         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        % make motion objects
        for i=1:20
            m(i)=stimuli.MotionObject(p);
        end
        p.trial.(sn).m=m;
        arrayfun(@(x) x.setup, m)
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
end