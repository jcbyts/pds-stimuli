%%
% addpath Repos/PLDAPStools/
% uses:
% 
% runAnalysis (in huklabBasics) should be replaced with runModularTrial(p, true)
% 
% you also need to replace the trialStateFunction that calls pldapsDefaultTrialFunction 
% with something that copies over what you need, check out opticflow.analysisReplay, 
% specifically
%  trialPrepare, trialSetup and frameUpdate
%     and don't call pldapsDefaultTrialFunction for stuff you don't want 
% (see opticflow.analysisReplay where I don't actually draw, you might have 
% to draw for your purpose though.
% 
% functionLevels stuff could be replace by my newer
% [pa, trialLevelMatrix, nTrials] = recreateParams(PDS) fucntion in PLDAPStool
% in theory.
% 
% have fun, let me know what you don't get, but sparsely if possible
% %% get a PDS 
% meta = io.getExperimentsAnd;
% thisSession = meta(end-1,:);
% disp(thisSession)
% sess = io.loadSession(thisSession);
% pds = io.getPds(sess);

%%
% PDS = pds{1};
load('Z:\Data\PLDAPS\PDS_bkp\Ellie20180312runFaceForageHartley1323.PDS', '-mat');


%%
sca
[pa, trialLevelMatrix] = recreateParams(PDS);

% iTrial=find(cellfun(@(x) x.natImgBackground.use, PDS.conditions));
% iTrial=iTrial(2);

iTrial = 1;
pa.setLevels(trialLevelMatrix(:,iTrial));


% pa.natImgBackground.imgDir = getpref('pep', 'colonyPics');
% pa.natImgBackground

% im = imread(fullfile(pa.natImgBackground.imgDir, pa.natImgBackground.fileList(pa.natImgBackground.imgIndex).name));
% figure(1); clf
% imshow(im)
% pa.natImgBackground.texToDraw=pa.natImgBackground.imgIndex;
% pa.pldaps.iTrial = iTrial;
%



p=pldaps;

% pa.display = p.defaultParameters.display;
% pa.datapixx.use = false;

% modify display parameters so the screen opens
pa.display.scrnNum = max(Screen('Screens'));
pa.display.screenSize = pa.display.winRect + [1e3 0 1e3 0];
pa.display.useOverlay = 0;
pa.display.switchOverlayCLUTs = 1;
pa.datapixx.use = false;

% pa.setLevels(1);
p.defaultParameters=pa;
p.trial=pa;

pa.datapixx.use




p.openScreen

%
% % 
% p.trial.pldaps.modNames.all = getModules(p, 0);
% % 
% % % experimentSetup before openScreen to allow modifyiers
% [moduleNames, moduleFunctionHandles, moduleRequestedStates, moduleLocationInputs] = getModules(p);
% %         
% % run all modules state experimentPreOpenScreen
% moduleRequestedStates.experimentPreOpenScreen = 1:numel(moduleNames);
%%         
moduleRequestedStates.experimentPostOpenScreen = 1;
runStateforModules(p,'experimentPostOpenScreen', {'hartley'}, {str2func(pa.hartley.stateFunction.name)}, moduleRequestedStates, true);
% 
% 

%
% iTrial=6;
% pa.setLevels(trialLevelMatrix(:,iTrial));

% turn off all devices -- we're not using them
% pa.datapixx.use = false;
pa.eyelink.use = false;
pa.sound.use = false;
pa.newEraSyringePump.use = false;

pa.display.scrnNum = max(Screen('Screens'));
% pa.display.screenSize = pa.display.winRect + [1.5e3 0 1.5e3 0];
pa.display.useOverlay = 0;
pa.display.switchOverlayCLUTs = 1;
pa.display.overlayptr = pa.display.ptr;
pa.pldaps.draw.framerate.use = 0; % turn off framerate

% pa.display.monkeyCLUT = pa.display.humanCLUT;

p.trial=pa;
p.trial = mergeToSingleStruct(p.trial);

p.data=PDS.data;
p.trial.sound.use=0;
p.trial.iFrame=1;
p.trial.pldaps.draw.grid.use=0;
p.trial.pldaps.draw.cursor.use=0;

%
% TOTAL HACK
if isfield(p.trial, 'faceforage') && p.trial.forage.use
    id = p.trial.faceforage.hTargs.objects.id;
    p.trial.faceforage.hTargs.objects = stimuli.objects.face(p, 'maxContrast', p.trial.faceforage.hTargs.maxContrast);
    p.trial.faceforage.hTargs.objects.id = id;
end
fn = fieldnames(p.trial.display.clut);
p.trial.display.clut = PDS.initialParametersMerged.display.clut; % take what was shown
for i = 1:numel(fn)
    p.trial.display.clut.(fn{i}) = p.trial.display.humanCLUT(p.trial.display.clut.(fn{i})(1)+1,:);
end

showWin = false;
[I,I2]=replayModularTrial(p,[0 0 200 200], true, showWin, [100 1100]);

sca
%
% figure(1); clf
% for k=1:size(I,4)
% imagesc(I2(:,:,:,k)); drawnow; pause(.015)
% end


%% draw full screen

fname='hartley_mov1.mp4';

% Prepare the new file.
if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fname, 'MPEG-4'); %'Uncompressed AVI');   
vidObj.Quality = 100;
vidObj.FrameRate=60;

open(vidObj);

% delayTime = 1/60; %Screen refresh rate of 60Hz
for i = 1:size(I,4)
    % Gifs can't take RBG matrices: they have to be specified with the
    % pixels as indices into a colormap
    % See the help for imwrite for more details
%     [y, newmap] = cmunique(imageArray{i});
    
    %Creates a .gif animation - makes first frame, then appends the rest
%     if i==1
%         imwrite(y, newmap, 'Zero Phase.gif');
%     else
%         imwrite(y, newmap, 'Zero Phase.gif', 'DelayTime', delayTime, 'WriteMode', 'append');
%     end

    currFrame = struct('cdata', squeeze(I(:,:,:,i)), 'colormap', []);
    writeVideo(vidObj,currFrame);
end

% Close the file.
close(vidObj);

return
%%


%% draw clipped
fname='mov2.mp4';

% Prepare the new file.
if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fname, 'MPEG-4'); %'Uncompressed AVI');   
vidObj.Quality = 100;
vidObj.FrameRate=60;

open(vidObj);

% delayTime = 1/60; %Screen refresh rate of 60Hz
for i = 1:size(I,4)
    % Gifs can't take RBG matrices: they have to be specified with the
    % pixels as indices into a colormap
    % See the help for imwrite for more details
%     [y, newmap] = cmunique(imageArray{i});
    
    %Creates a .gif animation - makes first frame, then appends the rest
%     if i==1
%         imwrite(y, newmap, 'Zero Phase.gif');
%     else
%         imwrite(y, newmap, 'Zero Phase.gif', 'DelayTime', delayTime, 'WriteMode', 'append');
%     end

    currFrame = struct('cdata', squeeze(I2(:,:,:,i)), 'colormap', []);
    writeVideo(vidObj,currFrame);
end

% Close the file.
close(vidObj);
