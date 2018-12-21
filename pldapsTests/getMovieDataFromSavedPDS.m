
load('Z:\Data\PLDAPS\PDS_bkp\test20181214stimuli.pldapsDefaultTrial1417.PDS', '-mat');

trial = pds.getPdsTrialData(PDS);

iTrial = 1;
fname = fullfile(getpref('pep', trial(iTrial).HDmovies.moviedatabase), trial(iTrial).HDmovies.moviefilename);
obj = VideoReader(fname);
iFrame = 0;

iFrame = iFrame + 1;
obj.CurrentTime = trial(1).HDmovies.frameShown(iFrame);
frame = obj.readFrame();

imagesc(mean(frame,3)); colormap gray