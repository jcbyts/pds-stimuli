%% Test Stimulus Modules
% To map V1 RFs, we use a set of stimuli
% 1) pixelNoise
% 2) sparseNoise
% 3) gaussianNoise
% 4) natBackground
% 5) hartleyGratings

subject='test';
showGaussianBlobs=false;
showNatBackground=true;
showHartleyStimuli=false;
showHDmovie=false;
showCSDFlash=false;

behavior=@plain;
% behavior=@TestDotMotion;
% behavior=@fixationTrainingNoise;

%% Run experiment
assert(sum([showGaussianBlobs showCSDFlash showNatBackground showHartleyStimuli showHDmovie])==1, 'You must have one (and only one) stimulus module turned on')

sca
clear settingsStruct
Screen('Preference','ScreenToHead', 1,0,0);

% add modular trial functions
settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
settingsStruct.behavior.reward.defaultAmount=.01;
settingsStruct.display.displayName='BenQ';
settingsStruct.display.heightcm=30;
settingsStruct.display.widthcm=53;
settingsStruct.display.viewdist=20;

%--------------------------------------------------------------------------
% Turn off Eyelink if test mode
if strcmp(subject, 'test')
    settingsStruct.eyelink.use=false;
    settingsStruct.mouse.useAsEyepos=true;
else
    settingsStruct.eyelink.use=true;
end

%--------------------------------------------------------------------------
% Add natural background module
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

%--------------------------------------------------------------------------
% Add gaussian blob noise
sn='gaussianNoiseBlobs';
settingsStruct.(sn).stateFunction.name='v1mapping.gaussianNoiseBlobs';
settingsStruct.(sn).use=showGaussianBlobs;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
% important parameters
settingsStruct.(sn).N=3; % number in the base level
settingsStruct.(sn).levels=5; % number of levels
settingsStruct.(sn).contrast=.25;
settingsStruct.(sn).sigma0=1;


%--------------------------------------------------------------------------
% Add Hartley Stimulus
sn='hartley';
settingsStruct.(sn).stateFunction.name='v1mapping.hartleyStimuli';
settingsStruct.(sn).use=showHartleyStimuli;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
settingsStruct.(sn).OnDuration=2;
settingsStruct.(sn).OffDuration=2;
settingsStruct.(sn).contrast=.25;
settingsStruct.(sn).Freq0=.025;
settingsStruct.(sn).nOctaves=5;
settingsStruct.(sn).tfs=0;
settingsStruct.(sn).sfscale=10;

%--------------------------------------------------------------------------
% Add HD movie
sn='HDmovies';
settingsStruct.(sn).stateFunction.name='v1mapping.HDmovies';
settingsStruct.(sn).use=showHDmovie;
settingsStruct.(sn).stateFunction.acceptsLocationInput=false;
settingsStruct.(sn).stateFunction.order=1;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;



if settingsStruct.gaussianNoiseBlobs.use || settingsStruct.hartley.use
    settingsStruct.display.destinationFactorNew=GL_ONE;
    settingsStruct.display.sourceFactorNew=GL_ONE;
end

settingsStruct.datapixx.use=true;
settingsStruct.datapixx.LogOnsetTimestampLevel=0;
settingsStruct.display.useOverlay=2;
settingsStruct.display.switchOverlayCLUTs=0;
settingsStruct.pldaps.pause.preExperiment=false;

%
% settingsStruct.display.movie.create=1;
% settingsStruct.display.movie.width=1920;
% settingsStruct.display.movie.heigh=1080;

p=pldaps(behavior, settingsStruct);
p.trial.pldaps.pause.preExperiment=false;
p.run

%%
p=pldaps(@marmoview.faceForage, 'jnk');
% p.trial.eyelink.custom_calibration=false;

p.trial.pldaps.pause.preExperiment=false;
p.run

%%
figure(1); clf
plot(p.data{1}.timing.frameStateChangeTimes'*1000, '-')
