subject = 'test';
% 
% behavior = @stimuli.forage.faceWalk;
% behavior = @plain;

behavior = @stimuli.forage.faceFinder;



% showNatBackground  = true;

% gaussianContrast = .15;
% behavior = @stimuli.fixflash.defaultParameters;% 
showCSDFlash       = false;
showNatBackground  = true;
showGaussNoise     = false;
showHartleyStimuli = false;
showGaussianBlobs  = false;

settingsStruct = struct();
settingsStruct.display.destinationFactorNew = GL_ONE;
if showNatBackground
    settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;
else
    settingsStruct.display.sourceFactorNew = GL_ONE;
end
settingsStruct.display.colorclamp = 1;
settingsStruct.display.normalizeColor = 1;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount=.05;

settingsStruct.session.subject=subject;

settingsStruct.stimulus.fixWinRadius = 1.5;
settingsStruct.stimulus.fixPointRadius = .3;
settingsStruct.stimulus.holdDuration = 30; % frames (counter, not continuous)


%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name='v1mapping.natImgBackground';
settingsStruct.(sn).use=true;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).imageContrast = .5;


settingsStruct.pldaps.pause.preExperiment = false;

try
    cm = getpref('marmoview_calibration', subject);
    cm2 = cm(:,:,1)';
    cm2(:,:,2) = cm(:,:,2)';
    
    settingsStruct.eyelink.calibration_matrix = cm2;
    settingsStruct.eyelink.useRawData = true;
end



p = pldaps(behavior, settingsStruct);

p.run

return
%%
for tr = 1:numel(p.data)
    figure(1); clf
    plot(p.data{tr}.timing.frameStateChangeTimes'*1000, '-')
    title(sprintf('Trial %d', tr))
    pause
end


