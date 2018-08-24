% Additionally, it can be used as a model for testing other stimulus
% protocols

% --- setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files


% set blend function appropriately
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;

settingsStruct.display.normalizeColor = 1;
settingsStruct.display.colorclamp = 1;
% 
settingsStruct.display.destinationFactorNew = GL_ONE;
settingsStruct.display.sourceFactorNew = GL_ONE;

settingsStruct.display.useOverlay = 0;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% make everything bigger (viewdist scales the pixels per degree
% calculation)
settingsStruct.display.viewdist = 100; % cm
settingsStruct.pldaps.pause.preExperiment = false;

%% add module to test
sn = 'testing';
settingsStruct.(sn).stateFunction.name  = 'stimuli.tests.testDotUniformTrial';
settingsStruct.(sn).stateFunction.order = 2;    % when to run this module with respect to other modules
settingsStruct.(sn).use                 = true; % use this module    

% calling pldaps with @stimuli.pldapsDefaultTrial will make sure that
% pldaps takes all the measurements that are required for our modules
% (e.g., eye position)
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

%%

p.openScreen

%%

h = stimuli.objects.circles('position', p.trial.display.ctr(1:2), 'radius', 100);

h.weight = 10;

h.frameDraw(p)

Screen('Flip', p.trial.display.ptr, 0);

%%
n = 10;
th = 0:(360/n):(360-(360/n));
x = cosd(th)*100;
y = sind(th)*100;
h.weight = [];
h.position = bsxfun(@plus, p.trial.display.ctr(1:2),[x(:) y(:)]);
h.radius   = repmat(20, n , 1);

h.frameDraw(p)

Screen('Flip', p.trial.display.ptr, 0);