function p=fixationTrainingNoise(p)
    %% GTA demo with textures
    %
    %% this demo does not handle any random numbers yet, be sure to gerenrate, store and use a new seed
    p = defaultBitNames(p);
    %%get a random seed
    p.defaultParameters.stimulus.randomNumberGenerater = 'mt19937ar';
    p.trial.stimulus.rngs.sessionSeed=fix(1e6*sum(clock));
    p.trial.stimulus.rngs.sessionRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed', p.trial.stimulus.rngs.sessionSeed);
    if datenum(version('-date')) >= datenum('February 9, 2012') %strcmp(version, '7.14.0.739 (R2012a)')
        RandStream.setGlobalStream(p.trial.stimulus.rngs.sessionRNG);
    else
        RandStream.setDefaultStream(p.trial.stimulus.rngs.sessionRNG); 
    end
    p.defaultParameters.stimulus.rngs.trialSeeds = randi(2^32, [1e3 1]); %1e5
    sessionRNG=p.trial.stimulus.rngs.sessionRNG;

    %% Use default variables
    defaultColors(p);
    p.trial.stimulus.eyeW=8;
    
    %% Set the trial function

sn='noise';

%% this demo does not handle any random numbers yet, be sure to gerenrate, store and use a new seed
frate=p.trial.display.frate;
    
    noise.centerXY=[0;0];
    noise.nx=100;
    noise.ny=100;
    noise.type='sparse';
    noise.contrast=1;
    noise.checkSize=5;
    noise.start=1*frate;
    noise.duration=10*frate;
    % setup types of noise
%     noise=repmat(noise,4,1);
%     noiseTypes={'uniform', 'gaussian', 'binarized', 'sparse'};
%     noiseTypes={'sparse'};
%     for kNoise=1:numel(noiseTypes)
%         noise(kNoise).type=noiseTypes{kNoise};
%     end
%     
%     p.trial.(sn).noise=noise;
p.trial.(sn).stateFunction.name='noise.noise';
p.trial.(sn).use=true;
p.trial.(sn).stateFunction.acceptsLocationInput=true;
p.trial.(sn).stateFunction.order=-5;
p.trial.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
p.trial.(sn).stateFunction.requestedStates.experimentPreOpenScreen=true;
p.trial.(sn).stateFunction.requestedStates.trialSetup=true;
p.trial.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
p.trial.(sn).stateFunction.requestedStates.frameDraw=true;
p.trial.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
p.trial.(sn).noise=noise;
p.trial.(sn).eyeOffset=true;
p.trial.(sn).noiseOn=true;
    
    %% Use default variables
    defaultColors(p);
    p.trial.stimulus.eyeW=8;
    
    %% Set the trial function
    p.trial.pldaps.trialFunction='noise.noise';
        
    p.trial.(sn).endWhenAllDone=true;
    
    %% Trial Duration
    % max trial length - must be specified for data allocation
    p.trial.pldaps.maxTrialLength = 5;
    p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    
    %% Set the trial function
    p.trial.pldaps.trialFunction='gta.gta';
    p.trial.pldaps.trialMasterFunction = 'runModularTrial';

    sn='stimulus';
    
    %% create some motions
    p.trial.(sn).endWhenAllDone=true;
    
    maxX=4;
    maxY=4.0;
    xyOffset=[-0.0;-0.];

    %first rashbass target
    frate=p.trial.display.frate;
    
    %just one state, no fixation for now
    target.motionstates.directions=[0 0];
    target.motionstates.speeds=[0 0];
%     target.motionstates.duration=[-200, 1*frate]; %negative means number of frame fixatting
    target.motionstates.duration=[-1, 1*frate]; %negative means number of frame fixatting
    target.motionstates.fixationBreakConsequence=[1 0];%0: no consequence, %1 reset fixcounter,%2 increase abort elvel 3 :increase level and stop stimulus
    target.motionstates.fixationTimeout=[10 0]; %how long until fixation has to get acquired
    target.motionstates.fixationWindow=[1.5 0];
    target.motionstates.fixationType=[2 0];
    target.motionstates.proportionAbort=[0 0];%when a fixbreak is detected %normalize by number of targets of fixating any is succicient
    target.motionstates.proportionReward=[1 0]; %when end of state reached
    target.motionstates.proportionRewardAmount=[p.trial.behavior.reward.defaultAmount 0]; %when end of state reached      
    target.motionstates.drawObjectNr=[1 3];%index in to p.trial.stimulus.object()
    target.initialXY = [0;0];

    %% load textures
    MFL=load([marmoview.supportDataDir filesep 'MarmosetFaceLibrary.mat']);
    MFLData=struct2cell(MFL)';
    MFLName=fieldnames(MFL);
    theseFaces={'face01','face02','face03','face04','face05'  ...
     'face11','face12','face13','face14','face15'  ...
     'face21','face22','face23','face24','face25' };
    M=MFLData(ismember(MFLName,theseFaces));
    A.tex = nan(size(M));
    A.rtex = nan(size(M));
    A.texSizes = nan(2,size(M,2));
    
    bgColor=(p.trial.display.bgColor*256-1);
%     texture.ptr=Screen('OpenOffscreenWindow',-1,0,[ 0 0 max(cellfun(@(x) size(x,1), M)) max(cellfun(@(x) size(x,2), M))]);
%     texture.ctr=p.defaultParameters.stimulus.maxDotXYs'-0.5;
    

    for i = 1:length(M)
         %********** apply a Gaussian aperture as well ***********
        m=M{i};
        M1 = size(m,1);
        M2 = size(m,2);
        
        dist=(repmat((1:M1)'-M1/2,1,M2).^2 + repmat((1:M2)-M2/2,M1,1).^2);
        SIG = (M1/6)^2;
        dist(dist>(((M1/2)^2+(M2/2)^2)))=Inf;
        dist=exp(-0.5*(dist/SIG));
        for dim=1:size(M{i},3)
           m(:,:,dim) = uint8(dist.*double(m(:,:,dim)) + (1-dist).*double(bgColor(dim)));
        end
        
        %this is not identical to what Jude does
        tmp = m;
        tmp(:,:,1)=0;
        tmp(:,:,3)=0;
        for dim=1:size(m,3)
           tmp(:,:,dim) = uint8(dist.*double(tmp(:,:,dim)) + (1-dist).*double(bgColor(dim)));
        end
               
%         tmp = M{i};
%         mtmp = mean(tmp,3);
%     %     zw = find(  );
%     %     zb = find(  );
%         mtmp(mtmp > (mean(bgColor)+50)) = 195;
%         mtmp(mtmp < (mean(bgColor)-50)) = 40;
%         
%         tmp(:,:,1)=mtmp;
%         tmp(:,:,2)=mtmp;      
    
        A.tex(i) = Screen('MakeTexture',p.trial.display.ptr,m);
        A.rtex(i) = Screen('MakeTexture',p.trial.display.ptr,tmp);
        A.texSizes(1,i) = M2;
        A.texSizes(2,i) = M1;
    end

    %% set up some objects to look at
    %a dot
%     pds.datapixx.init(p)
%      p.trial.display.overlayptr=Screen('OpenOffscreenWindow', p.trial.display.ptr, 0, [0 0 p.trial.display.pWidth p.trial.display.pHeight], 8, 32);
%     p.trial.display.overlayptr = PsychImaging('GetOverlayWindow', p.trial.display.ptr); % , dv.params.bgColor);
    object(1).type = 1; %dot
%     object(1).windowPtr = p.trial.display.ptr;%p.trial.display.ptr or p.trial.display.overlayPtr
    object(1).windowPtr = p.trial.display.ptr;%
    object(1).size=10;
    object(1).color=[1 0 0]; %p.trial.display.clut.targetnull;
    object(1).dotType=2;
    
    %a texture;
    object(2).type = 2; %texture   
    object(2).windowPtr = p.trial.display.ptr;%p.trial.display.ptr or p.trial.display.overlayPtr
    object(2).size=4;%deg
    object(2).texture=A.tex(1);
    object(2).stimRect=[[0;0];A.texSizes(:,1)];
    object(2).angle = 0;
    
%     object(3).type = 2; %texture   
%     object(3).windowPtr = p.trial.display.ptr;%p.trial.display.ptr or p.trial.display.overlayPtr
%     object(3).size=4;%deg
%     object(3).texture=A.tex(2);
%     object(3).stimRect=[[0;0];A.texSizes(:,2)];
%     object(3).angle = 0;
    
    object=[object(1) repmat(object(2), 1,size(A.texSizes,2))];
    
    tmp=num2cell(A.tex);
    [object(2:end).texture] = tmp{:};
    
    tmp=num2cell([repmat([0;0],1,size(A.texSizes,2));A.texSizes],1);
    [object(2:end).stimRect] = tmp{:};
   
    %add angles
%     angles=num2cell(repmat(0:10:350, 1, length(object)));
%     object=repmat(object, 1,36);
%     [object(2:end).angle] = angles{:};
    
	p.trial.(sn).object= object;
    p.trial.(sn).target= target;
   
    [p.conditions(1:200)]={struct};
    
    rXY=num2cell(diag([maxX,maxY])*(rand(sessionRNG,2,length(p.conditions))*2-1) + diag(xyOffset)*ones(2,length(p.conditions)),1);
    rd1=randi(sessionRNG,size(A.texSizes,2),[1,length(p.conditions)]);
    rd2=randi(sessionRNG,size(A.texSizes,2),[1,length(p.conditions)]);
    %this will create change appearance of 1->2
    rd2(rd2==rd1)= mod(rd2(rd2==rd1),size(A.texSizes,2))+1;
    rd1=rd1+1;
    rd2=rd2+1;
    
    
    for i=1:length(p.conditions)
        p.conditions{i}.(sn).target.initialXY = rXY{i};
%         p.conditions{i}.(sn).target.motionstates.drawObjectNr(1) = rd1(i);
        p.conditions{i}.(sn).target.motionstates.drawObjectNr(1) = 1;
        p.conditions{i}.(sn).target.motionstates.drawObjectNr(2) = rd2(i);
    end
    
    %% Trial Duration
    % max trial length - must be specified for data allocation
    p.trial.pldaps.maxTrialLength = 10;
    p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    
    %% Conditions
%     numReps = 10; % number of repetitions per condition
    
%     p.conditions=Shuffle(repmat({struct},1,numReps));

    % Set up the end of the experimental block
    p.defaultParameters.pldaps.finish = length(p.conditions); 
    
end