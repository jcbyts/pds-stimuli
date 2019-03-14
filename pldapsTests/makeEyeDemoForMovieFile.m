meta = io.getExperimentsAnd('StimulusProtocols', 'HDmovies');

bigTrial = [];

movieFname = 'PjAllen_Vid3.mp4';
sn = 'HDmovies';

for i = 1:size(meta,1)
    thisSession = meta(i,:);
    PDS = io.getPds(thisSession);
    
    trial = pds.getPdsTrialData(PDS);

    
    hasField = find(arrayfun(@(x) ~isempty(x.(sn)), trial));
    
    validTrials = hasField(arrayfun(@(x) x.(sn).use==1, trial(hasField)));

    movieFileTrial = arrayfun(@(x) x.(sn).moviefilename, trial(validTrials), 'uni', 0);
    bigTrial = [bigTrial; trial(validTrials(strcmp(movieFileTrial, movieFname)))];
end

%%
HEATMAP = false;

thisTrial = 1; 
fname = fullfile(getpref('pep', bigTrial(thisTrial).(sn).moviedatabase), bigTrial(thisTrial).(sn).moviefilename);
obj = VideoReader(fname);


tmpstr = strrep(movieFname(1:7), ' ', '_');
if HEATMAP
    fname = ['eyepos_heatmap_' tmpstr];
else
    fname = ['eyepos_' tmpstr];
end

if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fullfile(pwd, fname));
vidObj.Quality = 100;
vidObj.FrameRate=30;

open(vidObj)

f = figure(1); clf
f.Position = [0 0 1920 1080];
ax = gca;

eyex = arrayfun(@(x) x.behavior.eyeAtFrame(1,:), bigTrial, 'uni', 0);
eyey = arrayfun(@(x) x.behavior.eyeAtFrame(2,:), bigTrial, 'uni', 0);
nFrames = mode(cellfun(@numel, eyex));
idx = cellfun(@numel, eyex) ~= nFrames;
eyex(idx) = [];
eyey(idx) = [];


[xx,yy] = meshgrid(-5:5);

kern = exp( -xx.^2 + -yy.^2); kern = kern./sum(kern(:));

for iFrame = 300:nFrames-1

    if iFrame > 2
        x = cellfun(@(x) median(x(iFrame-2:iFrame+1)), eyex);
        y = cellfun(@(x) median(x(iFrame-2:iFrame+1)), eyey);
    else
        x = cellfun(@(x) x(iFrame), eyex);
        y = cellfun(@(x) x(iFrame), eyey);
    end




% 
%     if trial(thisTrial).HDmovies.frameShown(iFrame) <= 0
%         continue
%     end
    obj.CurrentTime = bigTrial(thisTrial).HDmovies.frameShown(iFrame);
    frame = obj.readFrame();
    hold off
    imagesc(ax, frame); hold on
    
    if HEATMAP
        [I,bins] = hist3([x y], {0:10:1920, 1:10:1080});
%         I = I ./ max(I(:));
        I = conv2(I, kern, 'same');
        % %     figure(1); clf
        h = imagesc(bins{1}, bins{2}, I', 'AlphaData', I'); hold on
        ax.CLim = [0 2];
    else
        
        for ii = 1:numel(x)
            plot(x(ii),y(ii), '.')
        end
    end
    drawnow
%     plot(cellfun(@(x) x(iFrame), eyex), cellfun(@(x) x(iFrame), eyey), '.', 'MarkerSize', 10, 'Color', 'c')
    
    currFrame = getframe(gca);
    
    writeVideo(vidObj,currFrame);

end


close(vidObj)
close all



%%%%%%%%%%%%%%%%

%%

%%

movieFileTrial = arrayfun(@(x) x.(sn).moviefilename, bigTrial, 'uni', 0);
%%
moviefiles     = unique(movieFileTrial);

nMov = numel(moviefiles);

fprintf('Found %d unique movies\n', nMov)

ROI 
fname = fullfile(getpref('pep', trial(thisTrial).(sn).moviedatabase), trial(thisTrial).(sn).moviefilename);
obj = VideoReader(fname);



tmpstr = strrep(moviefiles{iMovie}(1:5), ' ', '_');
fname = ['eyepos_' tmpstr];
if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fullfile(pwd, fname));
vidObj.Quality = 100;
vidObj.FrameRate=120;
open(vidObj);

f = figure(1); clf
f.Position = [0 0 1920 1080];
for iFrame = 1:numel(eyex{1})
    
    thisTrial = thisMovieIdx(iTrial);
    trial(thisTrial);
    
    if trial(thisTrial).HDmovies.frameShown(iFrame) <= 0
        continue
    end
    obj.CurrentTime = trial(thisTrial).HDmovies.frameShown(iFrame);
    frame = obj.readFrame();
    hold off
    imagesc(frame); hold on
    plot(cellfun(@(x) x(iFrame), eyex), cellfun(@(x) x(iFrame), eyey), '.', 'MarkerSize', 10, 'Color', 'c')
    
    currFrame = getframe(gca);
    
    writeVideo(vidObj,currFrame);
end

close(vidObj)
close all

%% Make Movie Demos
for iMovie = 3:-1:1
thisMovieIdx = validTrials(strcmp(movieFileTrial, moviefiles{iMovie}));

nTrials = numel(thisMovieIdx);

% load the movie object into memory
thisTrial = thisMovieIdx(1); % get the first trial this movie plays
fname = fullfile(getpref('pep', trial(thisTrial).(sn).moviedatabase), trial(thisTrial).(sn).moviefilename);
obj = VideoReader(fname);

[eyedata, timestamps] = io.getEyeData(thisSession, PDS);



ppd = trial(1).display.ppd;
ctr = trial(1).display.ctr(1:2);
eyex = arrayfun(@(x) x.behavior.eyeAtFrame(1,:), trial(thisMovieIdx), 'uni', 0);
eyey = arrayfun(@(x) x.behavior.eyeAtFrame(2,:), trial(thisMovieIdx), 'uni', 0);
idx = cellfun(@numel, eyex) ~= mode(cellfun(@numel, eyex));
eyex(idx) = [];
eyey(idx) = [];


tmpstr = strrep(moviefiles{iMovie}(1:5), ' ', '_');
fname = ['eyepos_' tmpstr];
if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fullfile(pwd, fname));
vidObj.Quality = 100;
vidObj.FrameRate=120;
open(vidObj);

f = figure(1); clf
f.Position = [0 0 1920 1080];
for iFrame = 1:numel(eyex{1})
    
    thisTrial = thisMovieIdx(iTrial);
    trial(thisTrial);
    
    if trial(thisTrial).HDmovies.frameShown(iFrame) <= 0
        continue
    end
    obj.CurrentTime = trial(thisTrial).HDmovies.frameShown(iFrame);
    frame = obj.readFrame();
    hold off
    imagesc(frame); hold on
    plot(cellfun(@(x) x(iFrame), eyex), cellfun(@(x) x(iFrame), eyey), '.', 'MarkerSize', 10, 'Color', 'c')
    
    currFrame = getframe(gca);
    
    writeVideo(vidObj,currFrame);
end

close(vidObj)
close all
end
%%





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

    
end

% Close the file.
close(vidObj);

%%
iFrame = 0;

iFrame = iFrame + 1;
obj.CurrentTime = trial(thisTrial).HDmovies.frameShown(iFrame);
frame = obj.readFrame();

imagesc(mean(frame,3)); colormap gray