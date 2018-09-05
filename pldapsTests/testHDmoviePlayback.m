
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

%%
dt = zeros((h.frameIndex(2)-h.frameIndex(1)), 1);
fr = zeros((h.frameIndex(2)-h.frameIndex(1)), 1);
for i=1:(h.frameIndex(2)-h.frameIndex(1))
%     h.update
    t0 = GetSecs;
    h.update
    h.draw
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
figure(1); clf
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