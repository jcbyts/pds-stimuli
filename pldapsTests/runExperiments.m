8%% Sample experiments

subject = 'Ellie'; % Ellie (Capitalized E)
pauseBeforeExperiment = 0;


%% Free View Natural Images

runNaturalImageFreeView(subject, pauseBeforeExperiment)

%% Fix Flash With Gaussian Pyramid Noise

runFixFlashWithGaussianPyrNoise(subject, pauseBeforeExperiment);

%% Fix Flash With Hartley

runFixFlashWithHartley(subject, pauseBeforeExperiment)

%% Fix Flash With White Noise

runFixFlashWithSparseNoise(subject, pauseBeforeExperiment);

%% Face Forage With Gaussian Pyramid Noise

runFaceForageGaussianPyrNoise(subject, pauseBeforeExperiment);

%% Face Forage with Hartley

runFaceForageHartley(subject, pauseBeforeExperiment);

%% Face Forage with CSD flash
runFaceForageCSD(subject, pauseBeforeExperiment);

%% MT mapping: Dot motion
runFaceForageDotMapping(subject, pauseBeforeExperiment, ...
    'targetSpeed', 2, ...       % degrees/sec
    'dotSpeeds', [15 20 25], ... % degrees/sec
    'apertureSize', 1, ...       % degrees
    'dotContrast', .2, ...      % ~Michelson contrast
    'onDuration', 6, ...  % in frames
    'offDuration', 1, ... % in frames
    'numDirections', 12, ... 
    'gazeContingent', false, ...
    'holdDuration', 15, ... % frames
    'task', 'fixflash', ... % oddball, faceinvaders, fixflash
    'randomizeDirections', true);

%%

subject = 'test';
pauseBeforeExperiment = true;

settingsStruct = struct();
% settingsStruct.display.destinationFactorNew = GL_ONE;

settingsStruct.display.colorclamp = 1;
settingsStruct.display.normalizeColor = 1;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount= 0.05; %.015;

settingsStruct.session.subject=subject;

settingsStruct.stimulus.fixWinRadius = 1.5;
settingsStruct.stimulus.fixPointRadius = .3;
settingsStruct.stimulus.holdDuration = 15; % frames (counter, not continuous)
settingsStruct.stimulus.RfCenterXy = [2 -2];
settingsStruct.stimulus.DotCenterAngle(1) = 0;
settingsStruct.stimulus.DotCenterAngle(2) = -90;

settingsStruct.pldaps.draw.cursor.use = true;


if pauseBeforeExperiment
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

% try
%     cm = getpref('marmoview_calibration', subject);
%     cm2 = cm(:,:,1)';
%     cm2(:,:,2) = cm(:,:,2)';
%     
%     settingsStruct.eyelink.calibration_matrix = cm2;
%     settingsStruct.eyelink.useRawData = true;
% catch me
%     throw(me)
% end

settingsStruct.eyelink.use = false;
settingsStruct.mouse.useAsEyepos = true;

p = pldaps(@stimuli.dotselection.OneInRF, subject, settingsStruct);

p.run

