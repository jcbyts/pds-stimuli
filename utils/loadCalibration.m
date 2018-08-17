function S = loadCalibration(S)

% try to load calibration
try
    cm = getpref('marmoview_calibration', S.session.subject);
    cm2 = cm(:,:,1)';
    cm2(:,:,2) = cm(:,:,2)';
    
    S.eyelink.calibration_matrix = cm2;
    S.eyelink.useRawData = true;
    
    S.arrington.calibration_matrix = cm2;
catch
    warning('error loading calibration: it didn''t work')
    return
end

if (strcmp(S.session.subject,'test'))
  S.eyelink.use = false;
  S.eyelink.useAsEyepos = false;
  S.arrington.use = false;
  S.arrington.useAsEyepos = false;
  S.mouse.useAsEyepos = true;
end