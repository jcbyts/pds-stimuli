function runSpatialMapping(subject, pauseBeforeStart, varargin)

ip = inputParser();
ip.addParameter('lifetime', 3)
ip.addParameter('N', 3)
ip.addParameter('size', 2)
ip.addParameter('contrast', -.2)
ip.addParameter('task', 'fixflash')
ip.addParameter('mappingStimulus', 2)
ip.addParameter('onDuration', 60)
ip.addParameter('offDuration', 60)
ip.addParameter('holdDuration', 30)
ip.addParameter('position', []) % empty is full-field
ip.addParameter('targetSpeed', 10)

ip.parse(varargin{:});

if nargin < 2
    pauseBeforeStart = true;
    if nargin < 1
        subject = 'Ellie';
    end
end

settingsStruct = struct();
settingsStruct.display.destinationFactorNew = GL_ONE;

settingsStruct.display.colorclamp = 1;
settingsStruct.display.normalizeColor = 1;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount= 0.025; %.015;

settingsStruct.session.subject=subject;

settingsStruct.stimulus.fixWinRadius = 1.5;
settingsStruct.stimulus.fixPointRadius = .3;
settingsStruct.stimulus.holdDuration = 15; % frames (counter, not continuous)

settingsStruct.pldaps.draw.cursor.use = true;


switch ip.Results.task
        case 'fixflash'
        behavior = @stimuli.fixflash.defaultParameters;
        sn = 'stimulus';
        s = struct(sn, struct());
        s.Nr = 1;
        s.stimulus.fixWinRadius = 1.5;
        
%         settingsStruct.stimulus.fixWinRadius   = 1.5;
        settingsStruct.stimulus.fixPointRadius = .3;
        
    case 'faceforage'
        behavior = @stimuli.forage.faceForageRandomWalk;
        sn  = 'stimulus';
        s = struct(sn, struct());
        s.Nr = 1;
        s.(sn).MotN       = 2;  % number of face objects
        s.(sn).minSpeed   = ip.Results.targetSpeed;  % minumum speed of face objects
        s.(sn).maxSpeed   = ip.Results.targetSpeed;
        s.(sn).motionType = 'randomwalk'; % randomwalk or linear
        s.(sn).type       = 'face';       % face or grating
        s.(sn).appearGazeContingent = false;
        s.(sn).appearRangePar = 2;
        s.(sn).appearCenter = [0 -2];
        s.(sn).appearTau = 1;
        s.(sn).maxContrast = 0.3;
        s.(sn).radius = 1;
        s.(sn).onLifetime  = 120;
        s.(sn).offLifetime = 240;
        s.(sn).holdDuration = ip.Results.holdDuration;
        % if type is 'grating', these parameters will be used
        s.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
            'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
        
    case 'faceinvaders'
        behavior = @stimuli.forage.faceForageRandomWalk;
        sn  = 'stimulus';
        s = struct(sn, struct());
        s.Nr = 1;
        s.(sn).MotN       = 2;  % number of face objects
        s.(sn).minSpeed   = ip.Results.targetSpeed;  % minumum speed of face objects
        s.(sn).maxSpeed   = ip.Results.targetSpeed;
        s.(sn).motionType = 'linear'; % randomwalk or linear
        s.(sn).type       = 'face';       % face or grating
        s.(sn).appearGazeContingent = false;
        s.(sn).appearRangePar = 2;
        s.(sn).appearCenter = [0 -2];
        s.(sn).appearTau = 1;
        s.(sn).maxContrast = 0.3;
        s.(sn).radius = 1;
        s.(sn).onLifetime  = 120;
        s.(sn).offLifetime = 240;
        s.(sn).holdDuration = ip.Results.holdDuration;
        % if type is 'grating', these parameters will be used
        s.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
            'phase', 0:(360/4):(360 - (360/4)), 'isgabor', true};
        
    case 'oddball'
        behavior = @stimuli.forage.faceForageRandomWalk;
        
        sn  = 'stimulus';
        s = struct(sn, struct());
        s.Nr = 1;
        s.(sn).MotN       = 2;  % number of face objects
        s.(sn).minSpeed   = ip.Results.targetSpeed;  % minumum speed of face objects
        s.(sn).maxSpeed   = ip.Results.targetSpeed;
        s.(sn).motionType = 'linear'; % randomwalk or linear
        s.(sn).type       = 'dot';       % face or grating
        s.(sn).appearGazeContingent = false;
        s.(sn).appearRangePar = 2;
        s.(sn).appearCenter = [0 -2];
        s.(sn).appearTau = 1;
        s.(sn).maxContrast = ip.Results.dotContrast;
        s.(sn).radius = .5; %.15;
        s.(sn).onLifetime  = 120;
        s.(sn).offLifetime = 340;
        s.(sn).holdDuration = ip.Results.holdDuration;
        % if type is 'grating', these parameters will be used
        s.(sn).gratingParams = {'sf', [.25 .5 1], 'orientation', 0:(180/12):(180-(180/12)), ...
            'phase', 0:(360/4):(360 - (360/4)), 'isgabor', false};
    otherwise
        fprintf('Valid Task Options:\n')
        fprintf('%s\n', 'fixflash', 'faceforage', 'faceinvaders', 'oddball')
        error('runDotMapping: not a valid task')
        
end


% %--------------------------------------------------------------------------
% % Add natural background module
% sn='natImgBackground';
% settingsStruct.(sn).stateFunction.name='v1mapping.natImgBackground';
% settingsStruct.(sn).use=true;
% settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
% settingsStruct.(sn).stateFunction.order=-5;
% settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% % settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
% settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
% % settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
% settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
% settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
% settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
% settingsStruct.(sn).imageContrast = .5;


%--------------------------------------------------------------------------
% Add Dot Mapping Stimulus
sn='SpatialMapping';
if ip.Results.mappingStimulus==2
    settingsStruct.(sn).stateFunction.name='v1mapping.spatialSquares'; 
else
    settingsStruct.(sn).stateFunction.name='v1mapping.spatialSquares';
end
settingsStruct.(sn).use=true;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).lifetime            = ip.Results.lifetime;
settingsStruct.(sn).N                   = ip.Results.N;
settingsStruct.(sn).contrast            = ip.Results.contrast;
settingsStruct.(sn).size                = ip.Results.size;
if ~isempty(ip.Results.position)
    assert(numel(ip.Results.position)==4, 'Position must be a 1 x 4 of xy Upper left, xy Bottom right, in degrees relative to center of screen')
    settingsStruct.(sn).position = ip.Results.position;
end


if pauseBeforeStart
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

try
    cm = getpref('marmoview_calibration', subject);
    cm2 = cm(:,:,1)';
    cm2(:,:,2) = cm(:,:,2)';
    
    settingsStruct.eyelink.calibration_matrix = cm2;
    settingsStruct.eyelink.useRawData = true;
catch me
%     throw(me)
end

if strcmp(subject, 'test')
    settingsStruct.eyelink.use = false;
    settingsStruct.mouse.useAsEyepos = true;
end


% --- Open pldaps
p = pldaps(behavior, settingsStruct);

% --- Build conditions

% --- Condition 1: Behavior with Dot Mapping
iCond = 1;
c{iCond}.stimulus = s.stimulus;
% c{iCond}.natImgBackground.use        = false;
% c{iCond}.natImgBackground.on         = false;
c{iCond}.DotMapping.use              = true;
% % 
% % --- Condition 2: Behavior on Natural background
% iCond = 2;
% c{iCond}.stimulus = s.stimulus;
% c{iCond}.natImgBackground.use   = true;
% c{iCond}.natImgBackground.on    = true;
% c{iCond}.DotMapping.use         = false;

% --- setup number of conditions        
condN = ones(1,iCond);
condN(1) = 3;

condNums = [];
for iCond = 1:numel(c)
    condNums = [condNums ones(1,condN(iCond))*iCond]; %#ok<AGROW>
end

p.defaultParameters.pldaps.finish = 200;

condIdx = repmat(condNums, 1, ceil(p.defaultParameters.pldaps.finish/numel(condNums)));

for iTrial = (numel(p.data)+1):p.defaultParameters.pldaps.finish
    p.conditions{iTrial} = c{condIdx(iTrial)};
end

% --- Run
p.run
