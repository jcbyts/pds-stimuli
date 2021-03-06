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
hFix = stimuli.objects.fixation();
hFix.position = p.trial.display.ctr(1:2);
hFix.stimValue = 1;

% choice targets
hChoice = stimuli.objects.circles('position', p.trial.display.ctr(1:2), 'radius', 100);
n = 10;
th = 0:(360/n):(360-(360/n));
x = cosd(th)*100;
y = sind(th)*100;
hChoice.weight = [];
hChoice.position = bsxfun(@plus, p.trial.display.ctr(1:2),[x(:) y(:)]);
hChoice.radius   = repmat(20, n , 1);
hChoice.stimValue = 1;

% dots
hDots = stimuli.objects.dotsUniform('range', 10);

hDots.position = p.trial.display.ctr(1:2);
hDots.speed = 10;
hDots.direction = 90;

hDots.trialSetup(p); % initializes dot positions before a trial
hDots.setRandomSeed();
hDots.stimValue = 1;


%% draw


hDots.frameUpdate(p);
hDots.frameDraw(p);
hChoice.frameDraw(p);
hFix.frameDraw(p);

Screen('Flip', p.trial.display.ptr, 0);