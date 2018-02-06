
subject = 'Ellie';
pauseBeforeExperiment = false;

%% Natural Image Free View: warm up
imgDir = './Colony';

runBackgroundImage('behavior', 'freeview', 'imgDir', imgDir)

%% Fixation with spatial mapping

runSpatialMapping('subject', subject,...
    'pauseBeforeExperiment', pauseBeforeExperiment,...
    'behavior', 'fixation',...
    'rect', [0 0 5 -5])

%% 


