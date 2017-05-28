%% 

p = pldaps();

p.openScreen

%%


% this removes small zero errors in the electronics of the ColorCal
% ColorCal2('ZeroCalibration');

%%
devInfo = ColorCal2('DeviceInfo');

% get calibration matrix to correct measurements
cMatrix = ColorCal2('ReadColorMatrix');

meas = ColorCal2('MeasureXYZ');

correctedValues = cMatrix(1:3,:) * [meas.x; meas.y; meas.z];


%%

x = [];
for i = 1:255
Screen('FillRect', p.trial.display.ptr, i/255)

Screen('Flip', p.trial.display.ptr, 0)

meas = ColorCal2('MeasureXYZ');

correctedValues = cMatrix(1:3,:) * [meas.x; meas.y; meas.z];

x = [x; correctedValues'];
end

%%
plot(x(:,1), 'r'); hold on
plot(x(:,2), 'g')
plot(x(:,3), 'b')


xlabel('bit value')
ylabel('cd/m^2')

title(mean(x(128,:)))