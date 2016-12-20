function p = marmoviewCalibrationGrid(p)

%% Random seed
p = defaultBitNames(p);
p.defaultParameters.stimulus.randomNumberGenerater = 'mt19937ar';
p.trial.stimulus.rngs.sessionSeed=fix(1e6*sum(clock));
p.trial.stimulus.rngs.sessionRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed', p.trial.stimulus.rngs.sessionSeed);
if datenum(version('-date')) >= datenum('February 9, 2012') %strcmp(version, '7.14.0.739 (R2012a)')
    RandStream.setGlobalStream(p.trial.stimulus.rngs.sessionRNG);
else
    RandStream.setDefaultStream(p.trial.stimulus.rngs.sessionRNG);
end
p.defaultParameters.stimulus.rngs.trialSeeds = randi(2^32, [1e3 1]); %1e5

%% Default Colors

defaultColors(p);
p.trial.stimulus.eyeW=8;

%% Set the trial function
p.trial.pldaps.trialFunction='gta.gta';

sn='stimulus';

%% create targets
p.trial.(sn).endWhenAllDone=true;

frate=p.trial.display.frate;

% build targets
target.motionstates.directions=0;
target.motionstates.speeds=0;
target.motionstates.duration=20*frate; %negative means number of frame fixating
target.motionstates.fixationBreakConsequence=0;%0: no consequence, %1 reset fixcounter,%2 increase abort elvel 3 :increase level and stop stimulus
target.motionstates.fixationTimeout=inf; %how long until fixation has to get acquired
target.motionstates.fixationWindow=2;
target.motionstates.fixationType=0;
target.motionstates.proportionAbort=0;%when a fixbreak is detected %normalize by number of targets of fixating any is succicient
target.motionstates.proportionReward=0; %when end of state reached
target.motionstates.proportionRewardAmount=0; %when end of state reached
target.motionstates.drawObjectNr=2;%index in to p.trial.stimulus.object()
target.initialXY = [0;0];

[y,x]=meshgrid([-8 -5 0 5 8]);
nTargets=numel(x);
target=repmat(target, nTargets,1);
for kTarg=1:nTargets
    target(kTarg).initialXY=[x(kTarg); y(kTarg)];
end

% load marmoset textures
A=loadUpMarmoFaces(p);

%% set up some objects to look at
% a dot
object(1).type = 1; %dot
object(1).windowPtr = p.trial.display.ptr;%p.trial.display.ptr or p.trial.display.overlayPtr
object(1).size=10;
object(1).color=[1 0 0];
object(1).dotType=2;

% invisible
object(2).type = 0; % invisible
object(2).windowPtr = p.trial.display.ptr;%p.trial.display.ptr or p.trial.display.overlayPtr

% marmoset face
object(3).type = 2; %texture
object(3).windowPtr = p.trial.display.ptr;%p.trial.display.ptr or p.trial.display.overlayPtr
object(3).size=4; % deg
object(3).texture=A.tex(1);
object(3).stimRect=[[0;0];A.texSizes(:,1)];
object(3).angle = 0;

object=[object(1:2) repmat(object(3), 1,size(A.texSizes,2))];

tmp=num2cell(A.tex);
[object(3:end).texture] = tmp{:};

tmp=num2cell([repmat([0;0],1,size(A.texSizes,2));A.texSizes],1);
[object(3:end).stimRect] = tmp{:};

p.trial.(sn).object= object;

%% Setup conditions
C=struct;
C.(sn).target=target;
[p.conditions(1:200)]={C};

% Set up the end of the experimental block
p.defaultParameters.pldaps.finish = length(p.conditions);

%% Trial Duration
% max trial length - must be specified for data allocation
p.trial.pldaps.maxTrialLength = 35;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

function A=loadUpMarmoFaces(p)
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
    
  
    sz = size(m);
    % gaussian envelope...
    x = [1:sz(1)]-sz(1)/2; y = [1:sz(2)]-sz(2)/2;
    [x,y] = meshgrid(x,y);
    g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
    g = g - min(g(:));
    g = g./max(g(:));
    m(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
    
    A.tex(i) = Screen('MakeTexture',p.trial.display.ptr,m);
    A.rtex(i) = Screen('MakeTexture',p.trial.display.ptr,tmp);
    A.texSizes(1,i) = M2;
    A.texSizes(2,i) = M1;
end