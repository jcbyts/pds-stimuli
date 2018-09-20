% Script for testing the objects that are required for the dotmotion module

% --- setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.openScreen;

pds.datapixx.init(p);
%% build test objects

% fixation
hFix = stimuli.objects.fixation();
hFix.position = p.trial.display.ctr(1:2);
hFix.stimValue = 1;
hFix.sz = 10;
hFix.ctrColor = p.trial.display.clut.white;
hFix.color    = p.trial.display.clut.black;
hFix.wincolor = p.trial.display.clut.redbg;

hFix.frameDraw(p);

Screen('Flip', p.trial.display.ptr, 0);
Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.bg)
%% choice targets
hChoice = stimuli.objects.circles('position', p.trial.display.ctr(1:2), 'radius', 100);
n = 10;
th = 0:(360/n):(360-(360/n));
x = cosd(th)*100;
y = sind(th)*100;
hChoice.weight = [];
hChoice.position = bsxfun(@plus, p.trial.display.ctr(1:2),[x(:) y(:)]);
hChoice.radius   = repmat(20, n , 1);
hChoice.stimValue = 1;
hChoice.color = p.trial.display.clut.white;

hChoice.frameDraw(p);

Screen('Flip', p.trial.display.ptr, 0);
Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.bg)

%%
% dots
hDots = stimuli.objects.dotsUniform('range', 10);

hDots.position = p.trial.display.ctr(1:2);
hDots.speed = 10;
hDots.direction = 45;
hDots.color = p.trial.display.clut.greenbg;

hDots.setRandomSeed();
hDots.trialSetup(p); % initializes dot positions before a trial
hDots.frameUpdate(p);
% hDots.setRandomSeed();
hDots.stimValue = 1;

hDots.frameDraw(p);

if p.trial.display.ptr==p.trial.display.overlayptr
    p.trial.display.clut.bg = [.5 .5 .5];
end
Screen('Flip', p.trial.display.ptr, 0);
Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.bg)

iFrame = 1;
xd = {};
yd = {};
xd{iFrame} = hDots.x;
yd{iFrame} = hDots.y;
%% draw all objects


hDots.frameUpdate(p);

hChoice.frameDraw(p);
hDots.frameDraw(p);
hFix.frameDraw(p);
iFrame = iFrame + 1;
xd{iFrame} = hDots.x;
yd{iFrame} = hDots.y;

Screen('Flip', p.trial.display.ptr, 0);
Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.bg)


%%

[x, y] = hDots.regenerateDots;

for iFrame = 1:numel(x)
    figure(1); clf
    plot(x{iFrame}, y{iFrame}, 'o'); hold on
    plot(xd{iFrame}, yd{iFrame}, '.');
    pause
end