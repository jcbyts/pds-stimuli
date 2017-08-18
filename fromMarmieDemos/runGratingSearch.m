%% Test Stimulus Modules
% To map V1 RFs, we use a set of stimuli
% 1) pixelNoise
% 2) sparseNoise
% 3) gaussianNoise
% 4) natBackground
% 5) hartleyGratings

subject='test';
showGaussianBlobs=false;
showNatBackground=false;
showHartleyStimuli=false;
showHDmovie=true;
showCSDFlash=false;
showSparseNoise=false;

% behavior=@plain;
% behavior=@TestDotMotion;
% behavior=@fixationTrainingNoise;
behavior=@stimuli.forage.gratingWalk;
%% Run experiment
assert(sum([showSparseNoise showGaussianBlobs showCSDFlash showNatBackground showHartleyStimuli showHDmovie])==1, 'You must have one (and only one) stimulus module turned on')

sca
settingsStruct = struct();
% Screen('Preference','ScreenToHead', 1,0,0);

% add modular trial functions
settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
settingsStruct.behavior.reward.defaultAmount=.01;


%--------------------------------------------------------------------------
% Turn off Eyelink if test mode
if strcmp(subject, 'test')
    settingsStruct.eyelink.use=false;
    settingsStruct.mouse.useAsEyepos=true;
else
    settingsStruct.eyelink.use=true;
    settingsStruct.eyelink.useRawData= true;
    settingsStruct.eyelink.calibration_matrix= getpref('marmoview_calibration', subject)';
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
% settingsStruct.(sn).moviefilename='/home/marmorig/Videos/HeadPokeTraining001.MP4';
settingsStruct.(sn).moviefilename='C:\Users\Jake\Videos\Ellie_01242017_Right1.avi';

%--------------------------------------------------------------------------
% Sparse noise
sn='sparseNoise';
settingsStruct.(sn).stateFunction.name='v1mapping.sparseNoise';
settingsStruct.(sn).use=showSparseNoise;
settingsStruct.(sn).stateFunction.acceptsLocationInput=false;
settingsStruct.(sn).stateFunction.order=1;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;

settingsStruct.(sn).contrast = .1;
settingsStruct.(sn).gazeContingent = false;
settingsStruct.(sn).xy = [1920 1080]/2;
settingsStruct.(sn).pxsize = 20;
settingsStruct.(sn).size = [100 100];


if settingsStruct.gaussianNoiseBlobs.use || settingsStruct.hartley.use
    settingsStruct.display.destinationFactorNew=GL_ONE;
    settingsStruct.display.sourceFactorNew=GL_ONE;
end

settingsStruct.datapixx.use=false;
settingsStruct.datapixx.LogOnsetTimestampLevel=0;
settingsStruct.display.useOverlay=0;
settingsStruct.display.switchOverlayCLUTs=0;
settingsStruct.pldaps.pause.preExperiment=false;

%
% settingsStruct.display.movie.create=1;
% settingsStruct.display.movie.width=1920;
% settingsStruct.display.movie.heigh=1080;

p=pldaps(behavior, settingsStruct);
p.trial.pldaps.pause.preExperiment=false;
p.run

