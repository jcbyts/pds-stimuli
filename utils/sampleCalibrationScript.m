
numMeasure = 17; % measure every point ( you can use less if you want a simple gamm correction)

ColorCALIICDCPort=[]; % look this up in your device manager. 
%If you don't know, try it with empty brackets and you may get lucky and the defalt will work

screenid=max(Screen('Screens')); % which screen to draw to
Screen('Preference', 'SkipSyncTests', 1);   % added by Jude, issue with IPAD



%% run the calibration
[ gammaTable1, gammaTable2, displayBaseline, displayRange, displayGamma, maxLevel, fullvals, inputValues] = CalibrateMonitorColorCal2PsychImaging(numMeasure, screenid, ColorCALIICDCPort);

% only save if sure
% save('ColorCal2MeasurementsNoHotMirror.mat')

%%  load gamma table and rerun calibration

load('ColorCal2MeasurementsNoHotMirror.mat')
figure(1); clf
plot([gammaTable1 gammaTable2])
legend({'Simple Gamma', 'Full Table'})

%%
[gammaTable1, gammaTable2, displayBaseline, displayRange, displayGamma, maxLevel, fullvals, inputValues] = CalibrateMonitorColorCal2PsychImaging(numMeasure, screenid, ColorCALIICDCPort, gammaTable2);


