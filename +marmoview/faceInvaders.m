function p=faceInvaders(p, state, sn)
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
    p.defaultParameters.pldaps.trialFunction='marmoview.faceInvaders';
    
    p.trial.pldaps.maxTrialLength = 5;
    p.trial.pldaps.maxFrames        = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    
    c.Nr=1; %one condition;
    p.conditions=repmat({c},1,200);
    
    p.defaultParameters.pldaps.finish = length(p.conditions);
    
    p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
    p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
    p.trial.exploded=0;
    
    %----------------------------------------------------------------------
    % Default Conditions
    p.trial.(sn).MotN       = 30;  % number of face objects
    p.trial.(sn).minSpeed   = 5;
    p.trial.(sn).maxSpeed   = 15;
    p.trial.(sn).motionType = 'linear';
    p.trial.(sn).forcefield = false;
    p.trial.(sn).type       = 'face';
    
    
    return
end



pldapsDefaultTrialFunction(p,state);
switch state
    
    %----------------------------------------------------------------------
    % Update all behavior of the objects
    case p.trial.pldaps.trialStates.frameUpdate
        a=GetSecs;
        p.trial.(sn).m.move()
        p.trial.(sn).m.isheld();
        b=GetSecs-a;
        disp(b)
    case p.trial.pldaps.trialStates.frameDraw

%         %***************** wipe out surround **********
%         hit = 0;
%         death = 0;
%         rad = 0;
%         itemhit = -1;
%         for i = 1:MotN
%              [hit,loc,rad,death] = p.trial.(sn).m(i).exploded();
%              if (hit == 1) 
%                  itemhit = i;
%                  break;
%              end
%         end
%         if (hit)
%             for i = 1:MotN
%                if (i ~= itemhit) 
%                   p.trial.(sn).m(i).wipeclear(loc,rad,death);
%                end
%             end
%         end
%         %*****************************************
        
        p.trial.(sn).m.draw()
%         Screen('DrawText', p.trial.display.ptr, num2str(p.trial.exploded), 50, 50, [1 1 1]);
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        %         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        p.trial.(sn).m = stimuli.MotionObjects(p, p.trial.(sn).MotN);
        p.trial.(sn).m.setup;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
    otherwise    
        
end
