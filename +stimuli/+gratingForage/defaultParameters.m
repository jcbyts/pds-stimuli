function defaultParameters(p, sn)
% SETUP create default values for running GRATINGFORAGE paradigm

if nargin < 2
    sn='stimulus';
end

% -------------------------------------------------------------------------
% --- PLDAPS setup
p = defaultBitNames(p);

p=stimuli.setupRandomSeed(p,sn);

defaultColors(p);

p=stimuli.clutColors(p);

p.trial.stimulus.eyeW=8;

% allow for other modules (e.g., backgrounds) to run
p.defaultParameters.pldaps.useModularStateFunctions = true;

p.defaultParameters.pldaps.trialFunction='stimuli.gratingForage.runTrial';

% -------------------------------------------------------------------------
% --- Parameters of the Grating Forage task

% --- Stimulus parameters
p.trial.(sn).bgColour 	   = .5; % pldaps controls this when the screen is opened

p.trial.(sn).nGratings       = 8;
p.trial.(sn).nOrientations   = 12;
p.trial.(sn).gratingRadius   = 1; % degrees
p.trial.(sn).gratingBuffer   = 2.5; % x radius
p.trial.(sn).gratingContrast = .1; % michelson contrast
p.trial.(sn).gratingSF       = 4; % cycles / degree
p.trial.(sn).isGabor         = true;
p.trial.(sn).holdDuration    = .1; % seconds;
p.trial.(sn).rewardRate      = .2;
p.trial.(sn).trialDuration   = 20; % seconds

p.trial.(sn).faceRadius = 1; % degree
p.trial.(sn).hGratings = stimuli.gratingForage.makeGratings(p);
p.trial.(sn).hNoise    = stimuli.gratingForage.makeGratings(p);

p.trial.(sn).fixWinRadius = 1.5;
p.trial.(sn).fixGracePeriod = .05;
p.trial.(sn).fixDuration = .1;
p.trial.(sn).trialTimeout = 10;
p.trial.(sn).iti = 1;

% -------------------------------------------------------------------------
% --- setup stimuli and prepare to run

% --- Face Textures
hFace = stimuli.textures(p.trial.display.ptr);

% load marmoset face textures
MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
MFL = struct2cell(MFL);
MFL = MFL([7,10,13,17:20,24,25,27]); % these faces seem most centered

for id = 1:length(MFL)
    img = MFL{id};
    
    sz = size(img);
    % gaussian envelope...
    x = (1:sz(1))-sz(1)/2; y = (1:sz(2))-sz(2)/2;
    [x,y] = meshgrid(x,y);
    g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
    g = g - min(g(:));
    g = g./max(g(:));
    img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
    
    hFace.addTexture(id, img);
end

p.trial.(sn).hFace = hFace;
p.trial.pldaps.draw.eyepos.use = false;

% -------------------------------------------------------------------------
% --- Plotting
% p.functionHandles.fixFlashPlot = stimuli.fixflash.fixFlashPlot;


% -------------------------------------------------------------------------
% --- Update Conditions
stimuli.gratingForage.updateConditions(p)
