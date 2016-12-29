function p=faceForage(p, state, sn)
% FACEFORAGE module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

MotN = 30;  % number of face objects

if nargin<3
    sn='faceForage';
end

if nargin==1
    Screen('Preference', 'TextRenderer', 1)
    
    p = pdsDefaultTrialStructure(p);
    
%     p.defaultParameters.pldaps.trialMasterFunction='runModularTrial';
    p.defaultParameters.pldaps.trialFunction='marmoview.faceForage';
    
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
    
    case p.trial.pldaps.trialStates.framePrepareDrawing,
        
        for i=1:MotN
            p.trial.(sn).m(i).move;
%         arrayfun(@(x) x.move, p.trial.(sn).m)
        end
        
    case p.trial.pldaps.trialStates.frameDraw,

        %***************** wipe out surround **********
%         hit = 0;
%         itemhit = -1;
%         for i = 1:MotN
%              [hit,loc,rad] = p.trial.(sn).m(i).exploded();
%              if (hit == 1)
%                  itemhit = i;
%                  break;
%              end
%         end
%         if (hit)
%             for i = 1:MotN
%                if (i ~= itemhit) 
%                   p.trial.(sn).m(i).wipeclear(loc,rad);
%                end
%             end
%         end
        %*****************************************
            
%         for i=1:MotN
%            p.trial.(sn).m(i).draw; 
%         end
        
%         p.trial.(sn).m(1).draw;
        arrayfun(@(x) x.draw, p.trial.(sn).m)
        Screen('DrawText', p.trial.display.ptr, num2str(p.trial.exploded), 50, 50, [1 1 1]);
%         
%         DrawFormattedText(p.trial.display.overlayptr, num2str(p.trial.exploded), 50, 50,  p.trial.display.clut.redbg);
    case p.trial.pldaps.trialStates.trialSetup,
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        %         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        % make motion objects
        for i=1:MotN
            m(i)=stimuli.MotionObject(p);
            % m(i)=stimuli.MotionObject(p,'radius',(3+rand*3));
        end
        p.trial.(sn).m=m;
        arrayfun(@(x) x.setup, m)
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave,
        
    otherwise    
        
end
