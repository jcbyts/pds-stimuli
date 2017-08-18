sca
% clear settingsStruct
settingsStruct.display.colorclamp     = 0;
settingsStruct.display.normalizeColor = 1;
settingsStruct.display.destinationFactorNew=GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew=GL_SRC_ALPHA;

% settingsStruct.display.destinationFactorNew=GL_ONE;
% settingsStruct.display.sourceFactorNew=GL_ONE;

p=pldaps(@plain, 'test', settingsStruct);

% p.trial.display.gamma.table= linspace(0,1,256)'*[1, 1, 1];
p=openScreen(p);
% p.trial.display.switchOverlayCLUTs=0;
% p.trial.display.useOverlay=2;
% p=pds.datapixx.init(p);

dots=stimuli.dots(p.trial.display.overlayptr, ...
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

p.trial.d=dots;

target=stimuli.fixation(p.trial.display.overlayptr, ...
    'centreSize', 5, ...
    'surroundSize', 5, ...
    'position', p.trial.display.ctr(1:2), ...
    'fixType', 1, ...
    'winType', 2, ...
    'centreColour', p.trial.display.clut.black, ...
    'surroundColour', p.trial.display.clut.white, ...
    'winColour', 2);

face = stimuli.textures

t=stimuli.targetAnnulus(p.trial.display.overlayptr, ...
    'radius', 100, ...
    'size', 5, ...
    'winSize', 6, ...
    'position', p.trial.display.ctr(1:2), ...
    'thetaSpan', [0 360], ...
    'colour', 2);

dots=p.trial.d;
dots.beforeTrial
t.beforeTrial





%%
% f.winRadius=f.winRadius+randn;
tic
dots.beforeFrame;
toc
dots.afterFrame;


target.position = target.position + randn(1,2);% %
% % d.colour=[0 0 0];
% t.draw;
target.drawFixation
% d.update;
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
