function p=v1mappingTest(p)


sn='stimulus';
p = pdsDefaultTrialStructure(p);

%         dv.defaultParameters.pldaps.trialMasterFunction='runTrial';
p.defaultParameters.pldaps.trialFunction='v1mapping.v1mappingForage';
%five seconds per trial.
p.trial.pldaps.maxTrialLength = 15;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;


%% Eye Trace Trail
p.trial.(sn).eyeTrailLength=1e3; % 4 seconds
p.trial.(sn).eyeTrailStep=5;

%% Background Image
p.trial.(sn).background.numToShow=10;

imageDatabase='CPSrange';
switch imageDatabase
    case 'Upenn'
        p.trial.(sn).background.imgDir='/media/marmorig/Data/tofu.psych.upenn.edu/fulldb/cd12B_closeup_ground_cover_woods_shade_sun/';
        p.trial.(sn).background.fileList=dir(fullfile(p.trial.(sn).background.imgDir,'*LUM.mat'));
        
    case 'CPSrange'
        p.trial.(sn).background.imgDir='/media/marmorig/Data/RangeDatabase1080p/';
        p.trial.(sn).background.fileList=dir(fullfile(p.trial.(sn).background.imgDir, 'lImage*V.png'));
end


% initialize no backgrounds
p.trial.(sn).background.on=false;
        
%% Noise

p.trial.(sn).noise.type='sparse';
p.trial.(sn).noise.dim=[10 10];
p.trial.(sn).noise.xy=[0 0];
p.trial.(sn).noise.checkSize=2;
p.trial.(sn).noise.sigma=.05;
p.trial.(sn).noise.on=true;
p.trial.(sn).noise.gazeContingent=true;



%% Forage Task




%% Build Conditions

c.Nr=1; %one condition;
p.conditions=repmat({c},1,200);

p.defaultParameters.pldaps.finish = length(p.conditions);

%% pldaps level stuff

% pause before experiment
p.trial.pldaps.pause.preExperiment=false;

% draw frame rate
p.trial.pldaps.draw.framerate.use=true;