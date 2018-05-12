function p = runFullFieldGratingReverseCorrelation(varargin)

ip = inputParser();
ip.addParameter('subject', 'jnk')
ip.addParameter('pauseBefore', false)
ip.addParameter('imageEveryNTrials', 4)
ip.addParameter('imgDir', getpref('pep', 'colonyPics'))
ip.addParameter('autoCorr', 'pBlank')
ip.parse(varargin{:})

% setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.display.sourceFactorNew = GL_ONE;
settingsStruct.display.destinationFactorNew = GL_ONE;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% subject name
settingsStruct.session.subject = ip.Results.subject;
% save PDS file as this experimental protocol
settingsStruct.session.experimentName = mfilename;

%--------------------------------------------------------------------------
% Add Hartley module
sn = 'grating';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.hartley.gratingTrialRevco';
settingsStruct.(sn).stateFunction.order = -1; % draw before behavior
settingsStruct.(sn).use = true;
settingsStruct.(sn).OnDuration  = 2;
settingsStruct.(sn).contrast    = .2;  % Michelson contrast of the gratings (DEPENDS ON BLEND FUNCTION)
settingsStruct.(sn).tfs         = 0;   % temporal frequencies showns
settingsStruct.(sn).sfs         = 2;
settingsStruct.(sn).numOrientations = 12;
settingsStruct.(sn).pBlank = .4; % probability of a blank frame

            
% frozen seed (each trial is the same sequence
settingsStruct.(sn).rngs.trialSeeds = repmat(666, 3e3, 1);

%--------------------------------------------------------------------------
% Add foraging module
sn = 'forage';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.forage.forage';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

settingsStruct.(sn).MotN                 = 3;            % number of moving targets
settingsStruct.(sn).minSpeed             = 1;            % minimum speed targets can move (deg/sec)
settingsStruct.(sn).maxSpeed             = 3;            % maximum speed (deg/sec)
settingsStruct.(sn).motionType           = 'randomwalk'; % motion follows this pattern (linear or randomwalk)
settingsStruct.(sn).type                 = 'face';       % face or grating
settingsStruct.(sn).appearGazeContingent = false;        % do the objects regenerate in a gaze-contingent coordinate frame
settingsStruct.(sn).appearRangePar       = 5;            % range of the generating distribution for the appearance of objects (deg)
settingsStruct.(sn).appearCenter         = [0 0];        % center of the regenerating distribution (deg, relative to center of screen)
settingsStruct.(sn).appearTau            = 10;            % do the objects fade on? (frames)
settingsStruct.(sn).maxContrast          = 1;            % contrast of the objects
settingsStruct.(sn).radius               = 1;            % radius of the objects (deg)
settingsStruct.(sn).onLifetime           = 1 * 120;      % time objects remain on (frames)
settingsStruct.(sn).offLifetime          = 2 * 120;      % time objects remain off (frames)   
settingsStruct.(sn).holdDuration         = 2;

if ip.Results.pauseBefore
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

settingsStruct = loadCalibration(settingsStruct);

% --- Open PLDAPS
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

% --- Run
p = p.run;