
p=pldaps(@stimuli.pldapsDefaultTrial);
p=openScreen(p);
p=pds.datapixx.init(p);

%%
% moviefilename='/home/marmorig/MyTestMovie.mov';
moviefilename='/home/marmorig/Videos/HeadPokeTraining001.MP4';
% moviefilename='/home/marmorig/test.avi';
% moviefilename='C:\Users\Jake\Downloads\scene.avi';
% if p.trial.display.useOverlay==2
h=stimuli.HDmovie(moviefilename, p.trial.display.ptr);
h.frameIndex=[9000 12000];
% h.frameIndex=[1 360];
h.open
Screen('Flip', p.trial.display.ptr)

d = stimuli.objects.dotsUniform(p.trial.display.ptr, 'position', p.trial.display.ctr(1:2));
d.trialSetup(p)
%%
h.start
dt = zeros((h.frameIndex(2)-h.frameIndex(1)), 1);
fr = zeros((h.frameIndex(2)-h.frameIndex(1)), 1);
for i=1:(h.frameIndex(2)-h.frameIndex(1))
%     runStateforModules(p,
%     h.update
    t0 = GetSecs;
    d.frameUpdate();
    d.frameDraw
%     h.drawNext()
    [h.movietexture, h.pts] = Screen('GetMovieImage', h.ptr, h.movie);%, 1, [], [], 0);
    
    if h.movietexture > 0
        % Yes. Draw the new texture immediately to screen:
        Screen('DrawTexture', h.ptr, h.movietexture, [], [0 0 h.dim(1) h.dim(2)]);
        
        % Release texture:
        Screen('Close', h.movietexture);
    end
    
    d.frameUpdate();
    d.frameDraw
    t1 = GetSecs - t0; 
    dt(i) = t1;
%     h.draw
    %     h.drawNext
    fr(i) = Screen('Flip', p.trial.display.ptr);
end

%%
h.closeMovie
%%
sca
figure; clf
subplot(2,1,1)
plot(dt*1e3, '.')
subplot(2,2,3)
histogram(dt*1e3)
subplot(2,2,4)
plot(diff(fr)*1e3, '.')

%% --- test with pldaps default trial added
p=pldaps(@stimuli.pldapsDefaultTrial, 'test');

stimuli.pldapsDefaultTrial(p, p.trial.pldaps.trialStates.experimentPreOpenScreen)

p=openScreen(p);
p=pds.datapixx.init(p);

p.trial = mergeToSingleStruct(p.trial);
% p.run

%%

moviefilename='/home/marmorig/Videos/HeadPokeTraining001.MP4';

h=stimuli.HDmovie(moviefilename, p.trial.display.ptr);
h.frameIndex=[9000 12000];

h.open
Screen('Flip', p.trial.display.ptr)

d = stimuli.objects.dotsUniform(p.trial.display.ptr, 'position', p.trial.display.ctr(1:2));
d.trialSetup(p)

stimuli.pldapsDefaultTrial(p, p.trial.pldaps.trialStates.experimentPostOpenScreen)
stimuli.pldapsDefaultTrial(p, p.trial.pldaps.trialStates.trialSetup)
stimuli.pldapsDefaultTrial(p, p.trial.pldaps.trialStates.trialPrepare)
%%
h.start
dt = zeros((h.frameIndex(2)-h.frameIndex(1)), 1);
fr = zeros((h.frameIndex(2)-h.frameIndex(1)), 1);
for i=1:(h.frameIndex(2)-h.frameIndex(1))
% %     runStateforModules(p,
    
    t0 = GetSecs;
    
    % draw movie
    h.update
    
    stimuli.pldapsDefaultTrial(p, p.trial.pldaps.trialStates.frameUpdate)
    
    h.draw
    
    stimuli.pldapsDefaultTrial(p, p.trial.pldaps.trialStates.frameDraw)

    % draw dots
%     d.frameUpdate();
%     d.frameDraw

    t1 = GetSecs - t0; 
    dt(i) = t1;
    
    %     h.drawNext
    fr(i) = Screen('Flip', p.trial.display.ptr);
end

%%
h.closeMovie
%%
sca
figure; clf
subplot(2,1,1)
plot(dt*1e3, '.')
subplot(2,2,3)
histogram(dt*1e3)
subplot(2,2,4)
plot(diff(fr)*1e3, '.')
%%
h.loadFrames
%%

for i=1:(h.frameIndex(2)-h.frameIndex(1))
h.drawFrame(i)
Screen('Flip', p.trial.display.ptr);
end

%%
h.closeMovie
Screen('Flip', p.trial.display.ptr)
%%
moviefilename='/home/marmorig/HeadPokeTraining001.MP4';
SimpleMovieDemo(moviefilename);
% LoadMovieIntoTexturesDemo(moviefilename, 5, 7)

%%
moviefilename='/home/marmorig/HeadPokeTraining001.MP4';
PlayMoviesWithoutGapDemo2(moviefilename);