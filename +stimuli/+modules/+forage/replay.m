function p=replay(p, state, sn)
% FACEFORAGE module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m



if nargin<3
    sn='stimulus';
end

switch state
    
%--------------------------------------------------------------------------
% --- Before Trial
    case p.trial.pldaps.trialStates.trialSetup
        
        % initialize replay frames
        p.trial.replay.replayedflipTimes=nan(size(p.data{p.trial.pldaps.iTrial}.timing.flipTimes));
            
        %change come colors
        p.trial.display.clut.hWhite = [1 1 1]';
        p.trial.stimulus.colorEyeDot = [77 175 74]'/255*.4;
        p.trial.display.clut.hDarkRed=[228 26 28]'/255*.4;
            
        % initialize tick display
        initTicks(p);
        
%         p.trial.display.px2w=p.trial.display.px2w.*[p.trial.replay.xfactor p.trial.replay.yfactor]';
        stimuli.forage.forage(p, state);
%         p.trial.display.px2w=p.trial.display.px2w./[p.trial.replay.xfactor p.trial.replay.yfactor]';
      
    case p.trial.pldaps.trialStates.trialPrepare
        stimuli.forage.forage(p,state)
        p.trial.unique_number = p.data{p.trial.pldaps.iTrial}.unique_number;
        p.trial.trstart = p.data{p.trial.pldaps.iTrial}.trstart;
        p.trial.stimulus.timeLastFrame = 0; %dv.trial.trstart;
        
        if p.trial.datapixx.use
            p.trial.timing.datapixxStartTime = p.data{p.trial.pldaps.iTrial}.timing.datapixxStartTime;
        end
        if p.trial.eyelink.use
            p.trial.timing.eyelinkStartTime = p.data{p.trial.pldaps.iTrial}.timing.eyelinkStartTime;
        end
        
        p.trial.ttime  = GetSecs - p.trial.trstart;
        p.trial.timing.syncTimeDuration = p.data{p.trial.pldaps.iTrial}.timing.syncTimeDuration;
        
    case p.trial.pldaps.trialStates.frameUpdate
        opticflow.opticflow(p,state)
        %set variables that would be set here?
        %i.e.Eyepos and have waitForFixation,etc.follow that?
        if p.data{p.trial.pldaps.iTrial}.iFrame==p.trial.iFrame+1
            p.trial.flagNextTrial=true;
        end
        if(size(p.data{p.trial.pldaps.iTrial}.stimulus.eyeXYs,2)<p.data{p.trial.pldaps.iTrial}.iFrame) && p.trial.iFrame>size(p.data{p.trial.pldaps.iTrial}.stimulus.eyeXYs,2)
            p.trial.eyeX=NaN;
            p.trial.eyeY=NaN;
        else
            p.trial.eyeX = p.data{p.trial.pldaps.iTrial}.data.eyeXYs(1,p.trial.iFrame)+p.trial.display.pWidth/2;
            p.trial.eyeY = p.data{p.trial.pldaps.iTrial}.eyelink.eyeXYs(2,p.trial.iFrame)+p.trial.display.pHeight/2;
        end
        
        % --- After Trial
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        %               %save out the data I calculated in frameDraw
        p.trial.keyboard.samplesTimes(:,p.trial.keyboard.samples+1:end) = [];
        p.trial.keyboard.samplesFrames(:,p.trial.keyboard.samples+1:end) = [];
        p.trial.keyboard.pressedSamples(:,p.trial.keyboard.samples+1:end) = [];
        p.trial.keyboard.firstPressSamples(:,p.trial.keyboard.samples+1:end) = [];
        p.trial.keyboard.firstReleaseSamples(:,p.trial.keyboard.samples+1:end) = [];
        p.trial.keyboard.lastPressSamples(:,p.trial.keyboard.samples+1:end) = [];
        p.trial.keyboard.lastReleaseSamples(:,p.trial.keyboard.samples+1:end) = [];
        p.trial.replay.keyboard=p.trial.keyboard;
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        stimuli.forage.forage(p,state);
    case p.trial.pldaps.trialStates.frameDraw
        stimuli.forage.forage(p,state);
        
    case p.trial.pldaps.trialStates.frameFlip
        stimuli.forage.forage(p,state);
        
        p.trial.replay.replayedflipTimes(:,p.trial.iFrame)=p.trial.timing.flipTimes(:,p.trial.iFrame);
        
        p.trial.timing.flipTimes(:,p.trial.iFrame)=p.data{p.trial.pldaps.iTrial}.timing.flipTimes(:,p.trial.iFrame);
        
        p.trial.stimulus.timeLastFrame = p.data{p.trial.pldaps.iTrial}.timing.flipTimes(3,p.trial.iFrame)-p.trial.trstart;
        p.trial.framePreLastDrawIdleCount=0;
        p.trial.framePostLastDrawIdleCount=0;

        
    otherwise    
        
end
