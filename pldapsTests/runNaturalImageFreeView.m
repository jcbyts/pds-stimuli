function p = runNaturalImageFreeView(subject, pauseBeforeStart, settingsStruct)

if nargin <3
    settingsStruct = struct();
    if nargin < 2
        pauseBeforeStart = false;
        if nargin < 1
            subject = 'test';
        end
    end
end

% --- Build parameters that specify
settingsStruct.display.destinationFactorNew = GL_ONE;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

settingsStruct.session.experimentName = mfilename;

settingsStruct.session.subject=subject;

%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name = 'v1mapping.natImgBackground';
settingsStruct.(sn).stateFunction.order = -1;
settingsStruct.(sn).use = true;
settingsStruct.(sn).imageContrast = .5;
settingsStruct.(sn).numToShow     = 1; % number of images to show per trial
% settingsStruct.(sn).imgDir = '/media/marmorig/Data/RangeDatabase1080p/';
% settingsStruct.(sn).fileList=dir(fullfile(p.trial.(sn).imgDir, 'lImage*V.png'));


% %--------------------------------------------------------------------------
% % Add faceforage module
% sn='faceforage';
% settingsStruct.(sn).stateFunction.name = 'stimuli.forage.forage';
% settingsStruct.(sn).stateFunction.order = 2;
% settingsStruct.(sn).use = true;

% -------------------------------------------------------------------------
% Add fixflash module
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.fixflash.default';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use = true;

if pauseBeforeStart
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end


% try
%     cm = getpref('marmoview_calibration', subject);
%     cm2 = cm(:,:,1)';
%     cm2(:,:,2) = cm(:,:,2)';
%     
%     settingsStruct.eyelink.calibration_matrix = cm2;
%     settingsStruct.eyelink.useRawData = true;
% end


p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run
