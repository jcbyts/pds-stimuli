subject = 'jnk';
pauseBeforeExperiment = false;

%% Natural Image Free View: warm up

p = runNaturalImageFreeView('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment, ...
    'imgDir', getpref('pep', 'colonyPics')); %#ok<*NASGU>



%% 

% run calibrationGUI(p) from pause to calibrate the eyes using gains and
% offsets (good enough for first pass)

p = runFullFieldGratingReverseCorrelation('subject', subject, ...
    'pauseBefore', pauseBeforeExperiment);



