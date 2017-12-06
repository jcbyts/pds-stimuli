function runDotSelection(subject, pauseBeforeExperiment)

if nargin < 2
    pauseBeforeExperiment = 0;
    if nargin < 1
        subject = 'test';
    end
end


settingsStruct = struct();
% settingsStruct.display.destinationFactorNew = GL_ONE;


settingsStruct.display.colorclamp = 1;
settingsStruct.display.normalizeColor = 1;

settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.behavior.reward.defaultAmount= 0.05; %.015;

settingsStruct.session.subject=subject;

settingsStruct.stimulus.fixWinRadius = 1.5;
settingsStruct.stimulus.fixPointRadius = .3;
settingsStruct.stimulus.holdDuration = 15; % frames (counter, not continuous)
settingsStruct.stimulus.RfCenterXy = [4 -4];
settingsStruct.stimulus.DotCenterAngle(1) = 0;
settingsStruct.stimulus.DotCenterAngle(2) = -90;

% The reward function I coded up will switch which target has the higher
% reward reate randomly with a switch rate of .1, meaning each trial a
% random number is drawn and if it is less than .1, the reward scheme will
% switch
settingsStruct.stimulus.rewardUpdateFun = @stimuli.dotselection.rewardUpdateSwitchRule;
settingsStruct.stimulus.rewardUpdateArgs = {.125}; % low rate, high rate

% initialize reward rate
settingsStruct.stimulus.rewardDot1Rate = .85;   %right stimulus
settingsStruct.stimulus.rewardDot2Rate = .10;  %left stimulus

settingsStruct.pldaps.draw.cursor.use = true;

if pauseBeforeExperiment
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

try
    cm = getpref('marmoview_calibration', subject);
    cm2 = cm(:,:,1)';
    cm2(:,:,2) = cm(:,:,2)';
    
    settingsStruct.eyelink.calibration_matrix = cm2;
    settingsStruct.eyelink.useRawData = true;
catch me
    throw(me)
end

if strcmp(subject, 'test')
    settingsStruct.eyelink.use = false;
    settingsStruct.mouse.useAsEyepos = true;
end

p = pldaps(@stimuli.dotselection.OneInRF, subject, settingsStruct);

p.run
