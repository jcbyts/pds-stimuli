
settingsStruct = struct();
settingsStruct.pldaps.nosave = true;
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.display.viewdist = 200;


%% add module to test
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.fixflash.runImgScan';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
settingsStruct.(sn).staircaseOn = true;
settingsStruct.(sn).minFixDuration = .2;
settingsStruct.(sn).shrinkTimeConstant = .1;
settingsStruct.(sn).fixationJitter = true;
settingsStruct.(sn).fixationJitterSize = .1;

%%
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.fixflash.runImgScan';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;
settingsStruct.(sn).staircaseOn = false;
settingsStruct.(sn).minFixDuration = 2;
settingsStruct.(sn).shrinkTimeConstant = 0;
settingsStruct.(sn).fixationJitter = false;
settingsStruct.(sn).fixationJitterSize = 0;



%% run pldaps
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run




%%

s = stimuli.fixationImg;
s.xyPix = p.trial.display.ctr(1:2);


%% calibration protocol?
s.radius = 15;
% s.wincolor = p.trial.display.clut.greenbg;
for j = 1:50
s.xyPix = randn(1,2).*50 + p.trial.display.ctr(1:2);
s.trialSetup(p)

for i = 1:40; s.frameUpdate(p); s.frameDraw(p); Screen('Flip', p.trial.display.ptr); end

end

%% fixation protocol
s.radius = 25;
s.xyPix = p.trial.display.ctr(1:2);
s.trialSetup(p)

for i = 1:540; s.frameUpdate(p); s.frameDraw(p); Screen('Flip', p.trial.display.ptr); end
Screen('Flip', p.trial.display.ptr);