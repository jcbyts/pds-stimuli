sca
% clear settingsStruct
settingsStruct.display.destinationFactorNew=GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew=GL_SRC_ALPHA;

p=pldaps(@plain, 'test', settingsStruct);

p=openScreen(p);
% p.trial.display.switchOverlayCLUTs=0;
p.trial.display.useOverlay=2;
p=pds.datapixx.init(p);


%% test pixel noise
iter=1;
while iter < 1e3
   
    if mod(iter,100)>0 && mod(iter,100) < 5
        Screen('FillRect', p.trial.display.ptr, 1);
        Screen('Flip', p.trial.display.ptr, 0);
    end
    Screen('FillRect', p.trial.display.ptr, 0);
        Screen('Flip', p.trial.display.ptr, 0);
    iter=iter+1;
end

%%

n=stimuli.pixelNoise(p.trial.display.ptr, 'type', 'sparse', 'sigma', .05);
n.xy = [400 400];
    n.pxsize=1;
    n.contrast = 1;
n.setup

iter=10;
while iter > 0
    
    n.update
    n.draw
    Screen('Flip', p.trial.display.ptr, 0);
    pause(.1)
    iter=iter-1;
end


%% test random seeds
n=stimuli.pixelNoise(p.trial.display.ptr, 'type', 'sparse', 'sigma', .05);
n.setup

for i = 1:10
n.update;
end
im1 = n.img;

figure(1); clf
subplot(131)
imagesc(im1)

n.rng.reset %(n.seed)
n.setup
for i = 1:10
n.update;
end
im2 = n.img;

subplot(132)
imagesc(im2)

im1==im2

%% test gaussian noise

n=stimuli.gaussianNoise(p.trial.display.ptr, 'contrast', .5, 'sc', p.trial.display.ppd, 'levels', 5, 'N', 2);
n.setup
Screen('Flip', p.trial.display.ptr, 0);
%% Draw
t0=GetSecs;
n.update
t1=GetSecs-t0;
fprintf('update took %0.5f ms\n', t1*1e3)

t0=GetSecs;
n.draw
t1=GetSecs-t0;
fprintf('draw took %0.5f ms\n', t1*1e3)
Screen('Flip', p.trial.display.ptr, 0);

%% Recreate Image
im=n.image;
img=Screen('GetImage', p.trial.display.ptr, [0 0 1920 1080]);
figure(1); clf
subplot(131); imagesc(mean(img,3)); colorbar; title('PTB image'); subplot(132); imagesc(im); colorbar; title('Matlab Evaluated Gaussians'); subplot(133); imagesc(mean(img,3)-(im)); colorbar; title('Difference')

figure(2); clf
imdiff=mean(img,3)-(im);
[i,j]=find(imdiff==max(imdiff(:)), 1);
plot(img(i,:,1)); hold on; plot(im(i,:))



%%
tex = CreateProceduralGaussBlob(p.trial.display.ptr, 150, 150, [0 0 0 0], 1, -.5);
%             n.tex2 = CreateProceduralGaussBlob(n.ptr, 150, 150, [1 1 1 0], 0, .5);
            
Screen('DrawTexture', p.trial.display.ptr, tex, [], [400 400 800 800], [], [], [], 0, [], kPsychDontDoRotation, [-.5, 10, 1, 0]);
Screen('DrawTexture', p.trial.display.ptr, tex, [], [400 400 800 800], [], [], [], 0, [], kPsychDontDoRotation, [.5, 10, 1, 0]);

Screen('Flip', p.trial.display.ptr, 0);

Screen('Close', tex)
%%

d=stimuli.dots(p, ...
    'size', 5, ...
    'speed', 5, ... 
    'direction', 90, ...
    'numDots', 30, ...
    'coherence', .5, ...
    'mode', 1, ...
    'dist', 1, ...
    'bandwdth', 50, ...
    'lifetime', 5, ...
    'maxRadius', 100, ...
    'position', p.trial.display.ctr(1:2));

p.trial.d=d;

f=stimuli.fixation(p.trial.display.overlayptr, ...
    'centreSize', 5, ...
    'surroundSize', 5, ...
    'position', p.trial.display.ctr(1:2), ...
    'fixType', 1, ...
    'winType', 2, ...
    'centreColour', p.trial.display.clut.black, ...
    'surroundColour', p.trial.display.clut.white, ...
    'winColour', 2);

t=stimuli.targetAnnulus(p.trial.display.overlayptr, ...
    'radius', 100, ...
    'size', 5, ...
    'winSize', 6, ...
    'position', p.trial.display.ctr(1:2), ...
    'thetaSpan', [0 360], ...
    'colour', 2);

d=p.trial.d;
d.beforeTrial
t.beforeTrial





%%
f.winRadius=f.winRadius+randn;
tic
d.draw;
toc
% d.colour=[0 0 0];
t.draw;
f.drawFixation
d.update;
Screen('Flip', p.trial.display.ptr, 0);
Screen('FillRect', p.trial.display.overlayptr, 0);

%% testing faces for faceforage
subject='test';
load settingsStruct.mat
settingsStruct.display.useOverlay=1;
settingsStruct.display.destinationFactorNew=GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew=GL_SRC_ALPHA;
settingsStruct.display.screenSize=[]; %[0 0 1500 900];
settingsStruct.pldaps.draw.grid.use=0;
% settingsStruct.display.switchOverlayCLUTs=1;
% sc='faceForage';
% settingsStruct.(sc).stateFunction.name='faceForage';
% settingsStruct.(sc).use=true;
% settingsStruct.(sc).stateFunction.acceptsLocationInput=true;
% settingsStruct.(sc).stateFunction.order=-5;
% settingsStruct.(sc).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.(sc).stateFunction.requestedStates.experimentPreOpenScreen=true;
% % settingsStruct.(sc).stateFunction.requestedStates.experimentCleanUp=true;
% settingsStruct.(sc).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.(sc).stateFunction.requestedStates.frameUpdate=true;
% settingsStruct.(sc).stateFunction.requestedStates.framePrepareDrawing=true;
% settingsStruct.(sc).stateFunction.requestedStates.frameDraw=true;
% settingsStruct.(sc).stateFunction.requestedStates.trialCleanUpandSave=true;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

p=pldaps(@faceForage,subject, settingsStruct);
%  p=pldaps(@gta.setup.dotGrid,subject, settingsStruct);
p = defaultBitNames(p);
p.trial.pldaps.useModularStateFunctions = true;
p.trial.pldaps.experimentAfterTrialsFunction=[];
p.trial.pldaps.pause.preExperiment=false;
p.run
