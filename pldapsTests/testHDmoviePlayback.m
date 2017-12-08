% setup some additional options

p=pldaps(@plain);
p=openScreen(p);
p=pds.datapixx.init(p);

%%
f = stimuli.fixationRsvp(p);


%%
f.switchRate = .05;
f.cSize = 50;
f.sSize = 60;
for i = 1:1e3
f.drawFixation
Screen('Flip', p.trial.display.ptr);
f.afterFrame
end
%% test hartley stimuli

h=stimuli.hartley(p.trial.display.ptr, 'ppd', 1./p.trial.display.ppd);

h.setup
%%

%%

h.kx=0;
h.ky=10;

h.draw
Screen('Flip', p.trial.display.ptr);

% m=randn(190, 180);
% tex=Screen('MakeTexture',p.trial.display.ptr,m);
% Screen('DrawTexture', p.trial.display.ptr, tex)
% Screen('Close', tex)
% Screen('Flip', p.trial.display.ptr, 0);
%%


p=pldaps(@plain);
p=openScreen(p);
p=pds.datapixx.init(p);

%%
% moviefilename='/home/marmorig/MyTestMovie.mov';
moviefilename='/home/marmorig/HeadPokeTraining001.MP4';
% moviefilename='/home/marmorig/test.avi';
moviefilename='C:\Users\Jake\Downloads\scene.avi';
% if p.trial.display.useOverlay==2
h=stimuli.HDmovie(moviefilename, p.trial.display.ptr);
h.frameIndex=[10000 11000];
% h.frameIndex=[1 360];
h.open

%%
for i=1:(h.frameIndex(2)-h.frameIndex(1))
%     h.update
    h.update
    h.draw
%     h.draw
    %     h.drawNext
    Screen('Flip', p.trial.display.ptr);
end

%%
h.closeMovie
%%
sca
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