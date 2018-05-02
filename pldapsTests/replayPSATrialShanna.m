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
load('Z:\Data\PLDAPS\Ellie\Ellie_2018-04-26_13-58-43_TungMT5\Ellie20180426runGaborTargetSelection1439.PDS', '-mat');


%%
sca
[pa, trialLevelMatrix] = recreateParams(PDS);

% iTrial=find(cellfun(@(x) isfield(x, 'dotselection'), PDS.conditions));
% iTrial=iTrial(2);
iTrial = 2;
pa.setLevels(trialLevelMatrix(:,iTrial));
% pa.natImgBackground.imgDir = getpref('pep', 'colonyPics');
% pa.natImgBackground
% 
% im = imread(fullfile(pa.natImgBackground.imgDir, pa.natImgBackground.fileList(pa.natImgBackground.imgIndex).name));
figure(1); clf
% subplot(1,2,1)
% imshow(im)
% pa.natImgBackground.texToDraw=pa.natImgBackground.imgIndex;
pa.pldaps.iTrial = iTrial;
% title(iTrial)
% 
% subplot(1,2,2)
plot(PDS.data{iTrial}.behavior.eyeAtFrame')

figure(1); clf
pa.pldaps.iTrial = iTrial;
title(iTrial)
% 

plot(PDS.data{iTrial}.behavior.eyeAtFrame(1,:), PDS.data{iTrial}.behavior.eyeAtFrame(2,:))
hold on
plot(PDS.initialParametersMerged.display.ctr(1), PDS.initialParametersMerged.display.ctr(2), '+k')
for i = 1:numel(PDS.data{iTrial}.dotselection.hTargs)
    plot(PDS.data{iTrial}.dotselection.hTargs(i).position(1), PDS.data{iTrial}.dotselection.hTargs(i).position(2), 'o')
end
axis ij

%%
sca
for iTrial = 10:15
pa.setLevels(trialLevelMatrix(:,iTrial));
% pa.natImgBackground.imgDir = getpref('pep', 'colonyPics');
% pa.natImgBackground
% 
% im = imread(fullfile(pa.natImgBackground.imgDir, pa.natImgBackground.fileList(pa.natImgBackground.imgIndex).name));
figure(1); clf
% subplot(1,2,1)
% imshow(im)
% pa.natImgBackground.texToDraw=pa.natImgBackground.imgIndex;
pa.pldaps.iTrial = iTrial;
% title(iTrial)
% 
% subplot(1,2,2)
plot(PDS.data{iTrial}.behavior.eyeAtFrame')




p=pldaps;

% pa.display = p.defaultParameters.display;
% pa.datapixx.use = false;
old_display = pa.display;

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
% 
% p.trial.pldaps.modNames.all = getModules(p, 0);
% 
% % experimentSetup before openScreen to allow modifyiers
% [moduleNames, moduleFunctionHandles, moduleRequestedStates, moduleLocationInputs] = getModules(p);
%         
% % run all modules state experimentPreOpenScreen
% moduleRequestedStates.experimentPreOpenScreen = 1:numel(moduleNames);
%         
% runStateforModules(p,'experimentPreOpenScreen', moduleNames, moduleFunctionHandles, moduleRequestedStates, moduleLocationInputs);
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
pa.pldaps.draw.grid.use = false;
% pa.display.monkeyCLUT = pa.display.humanCLUT;

p.trial=pa;
p.trial = mergeToSingleStruct(p.trial);

p.data=PDS.data;
p.trial.sound.use=0;
p.trial.iFrame=1;
p.trial.pldaps.draw.grid.use=1;
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


% p.trial.dotselection = rmfield(p.trial.dotselection, 'hTargs');
for i = 1:numel(p.trial.dotselection.hTargs)
    p.trial.dotselection.hTargs(i).gabortex = [];
    p.trial.dotselection.hTargs(i).setup(p);
end
p.trial.dotselection = rmfield(p.trial.dotselection, 'hFace');

moduleRequestedStates.experimentPostOpenScreen = 1;
runStateforModules(p,'experimentPostOpenScreen', {'dotselection'}, {str2func(pa.dotselection.stateFunction.name)}, moduleRequestedStates, true);

% p.trial.pldaps.iTrial = p.trial.pldaps.iTrial + 1;
[I,I2]=replayModularTrial(p,[-100 -100 100 100], true, true, [1 size(PDS.data{iTrial}.behavior.eyeAtFrame,2)]);

sca
%
% figure(1); clf
% for k=1:size(I,4)
% imagesc(I2(:,:,:,k)); drawnow; pause(.015)
% end


% draw full screen

fname=sprintf('psa_trial_mov%d.mp4', iTrial);

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


%

% draw clipped
fname=sprintf('psa_trial_mov_clipped%d.mp4', iTrial);

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

end
