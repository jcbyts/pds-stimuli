% Script for testing the objects that are required for the dotmotion module

% --- setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.openScreen
%% build test objects

% fixation
hGab = stimuli.objects.gabors();
hGab.setup(p)

%%
[xx, yy] = meshgrid(-5:2:5);
posxy = bsxfun(@plus, pds.deg2px([xx(:) yy(:)]', p.trial.display.viewdist, p.trial.display.w2px), p.trial.display.ctr(1:2)');
nGabors = numel(xx);

thetas = 0 * ones(1, nGabors);
phase = rand(1, nGabors)*360;
sigma = .1*ones(1, nGabors);
sf = 2*ones(1, nGabors);
contrast = .5*ones(1,nGabors);
tf = 10*ones(1, nGabors);

hGab.position = posxy';
hGab.phase = phase;
hGab.sigma = sigma;
hGab.sf = sf;
hGab.tf = tf;
hGab.theta = thetas;
hGab.contrast = contrast;


%% draw


hGab.frameUpdate(p);
hGab.frameDraw(p);

Screen('Flip', p.trial.display.ptr, 0);