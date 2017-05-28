subject = 'test';
% behavior = @stimuli.forage.gratingWalk;
behavior = @stimuli.fixflash.defaultParameters;

showCSDFlash      = false;
showNatBackground = false;

settingsStruct = struct();
settingsStruct.display.destinationFactorNew = GL_ONE;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;
settingsStruct.display.colorclamp = 0;
settingsStruct.display.normalizeColor = 0;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount=.01;

settingsStruct.session.subject=subject;

sn='csdFlash';
settingsStruct.(sn).stateFunction.name='v1mapping.csdFlash';
settingsStruct.(sn).use=showCSDFlash;
settingsStruct.(sn).stateFunction.acceptsLocationInput=false;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).onDuration = 50;
settingsStruct.(sn).offDuration = 150;
settingsStruct.(sn).onColor = 1;
settingsStruct.(sn).offColor = .5;

%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name='v1mapping.natImgBackground';
settingsStruct.(sn).use=showNatBackground;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;


p = pldaps(behavior, settingsStruct);

p.run

%% test noise stimuli

lev1 = stimuli.gaussians(p, 'sigma', [0.1 .25 .5 1]);
% lev2 = stimuli.gaussians(p, 'sigma', .25);
% lev3 = stimuli.gaussians(p, 'sigma', .5);
% lev4 = stimuli.gaussians(p, 'sigma', 1);

n1 = stimuli.textureFlashNoise(p,lev1, 'num', 4^4);
% n2 = stimuli.textureFlashNoise(p,lev2, 'num', 4^3);
% n3 = stimuli.textureFlashNoise(p,lev3, 'num', 4^2);
% n4 = stimuli.textureFlashNoise(p,lev4, 'num', 4);

%%
tic
n1.beforeFrame()
toc
% n2.beforeFrame()
% n3.beforeFrame()
% n4.beforeFrame()

Screen('Flip', p.trial.display.ptr);

tic
n1.afterFrame()
toc
% n2.afterFrame()
% n3.afterFrame()
% n4.afterFrame()

%%

n = stimuli.gaussianPyrNoise(p)

n.setup

%%
figure(1); clf
plot(n.x, n.y, 'o')

n.update

%% grating noise
n = stimuli.gratings(p);
%%
n = stimuli.gaussians(p, 'sigma', [0.1 .25 .5 1]);

%%
ng = 100;
% n.id = randi(n.numTex, 1, ng);
n.texSize = cell2mat(cellfun(@(x) x.size, n.texture(n.id), 'UniformOutput', false)');
n.alpha = repmat(.15, 1, ng);


n.position = n.position + 10*randn(ng,2); %rand(ng, 2)*600;
% n.position = rand(ng, 2)*600;
n.beforeFrame()

Screen('Flip', p.trial.display.ptr);
%%


% Screen('BlendFunction',  p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('BlendFunction',  p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE);
n = stimuli.gaussians(p, 'sigma', [0.1 .25 .5 1]);



n.id = [7 8];
n.texSize = cell2mat(cellfun(@(x) x.size, n.texture(n.id), 'UniformOutput', false)');
n.position = [p.trial.display.ctr(1:2); p.trial.display.ctr(1:2)+[0 50]];
n.alpha    = repmat(.1, 1, numel(n.id));

n.beforeFrame()
Screen('Flip', p.trial.display.ptr);

img=Screen('GetImage', p.trial.display.ptr, p.trial.display.winRect);

figure(1); clf
plot(mean(img,3)-127)


%%
p.trial.display.ptr = nan;
n = stimuli.gaussians(p, 'sigma', [0.1 .25 .5 1]);

n.id = [8 7];
n.texSize = cell2mat(cellfun(@(x) x.size, n.texture(n.id), 'UniformOutput', false)');
n.position = [p.trial.display.ctr(1:2); p.trial.display.ctr(1:2)+[0 0]];
n.alpha    = repmat(.15, 1, 2);

a = stimuli.textureFlashNoise(p, n)

a.getImage



%%
ng   = 100;
n.id = randi(numel(n.sigma), 1, ng);
n.texSize = repmat(ceil(7*n.sigma(n.id)*p.trial.display.ppd), 1, 2);
n.alpha = repmat(.15, 1, ng);
n.position = rand(ng, 2)*300;


n.beforeFrame()

Screen('Flip', p.trial.display.ptr);


img=Screen('GetImage', p.trial.display.ptr, p.trial.display.winRect);

%%

p.trial.display.ptr = nan;
