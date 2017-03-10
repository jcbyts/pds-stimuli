function p=afterTrialFunction(p, state, sn)

if nargin<3
    sn='marmoview';
end

switch state
        
   case p.trial.pldaps.trialStates.trialSetup
       hObj=MarmoView(1);%p.trial.(sn).
       handles=guidata(hObj);
       
       handles.OutputPanel.Visible     = 'On';
       handles.ParameterPanel.Visible  = 'On';
       handles.SettingsPanel.Visible   = 'On';
       handles.CloseGui.Visible        = 'On';
       handles.ControlsPanel.Visible   = 'On';
       handles.RunTrial.Enable         = 'Off';
       handles.FlipFrame.Enable        = 'Off';
       handles.PauseTrial.Enable       = 'Off';
       handles.EyeTrackerPanel.Visible = 'On';
       handles.GainDownX.Enable        = 'Off';
       handles.GainDownY.Enable        = 'Off';
       handles.GainUpX.Enable          = 'Off';
       handles.GainUpY.Enable          = 'Off';
       handles.ShiftDown.Enable        = 'Off';
       handles.ShiftUp.Enable          = 'Off';
       handles.ShiftLeft.Enable        = 'Off';
       handles.ShiftRight.Enable       = 'Off';
        
       handles.StatusText.String='Trial is running. Press P to pause';
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave 
        hObj=MarmoView(1);
        handles=guidata(hObj);
        switch p.trial.pldaps.quit
            case 2 % quit the program
                hObj=MarmoView(1);
                handles=guidata(hObj);
                handles.RunTrial.Enable         = 'Off';
                handles.FlipFrame.Enable        = 'Off';
                handles.PauseTrial.Enable       = 'Off';
                handles.EyeTrackerPanel.Visible = 'Off';
                handles.GainDownX.Enable        = 'Off';
                handles.GainDownY.Enable        = 'Off';
                handles.GainUpX.Enable          = 'Off';
                handles.GainUpY.Enable          = 'Off';
                handles.ShiftDown.Enable        = 'Off';
                handles.ShiftUp.Enable          = 'Off';
                handles.ShiftLeft.Enable        = 'Off';
                handles.ShiftRight.Enable       = 'Off';
                handles.ShowBackground.Enable   = 'Off';
                handles.ShowBlack.Enable        = 'Off';
                handles.CloseGui.Enable         = 'On';
                handles.ChooseSettings.Enable   = 'On';
                handles.StatusText.String='PLDAPS program quit';
                return
            case 1 % pause
                hObj=MarmoView(1);
                handles=guidata(hObj);
                handles.RunTrial.Enable         = 'On';
                handles.FlipFrame.Enable        = 'On';
                handles.PauseTrial.Enable       = 'Off';
                handles.EyeTrackerPanel.Visible = 'On';
                handles.CenterEye.Enable        = 'On';
                handles.GainDownX.Enable        = 'On';
                handles.GainDownY.Enable        = 'On';
                handles.GainUpX.Enable          = 'On';
                handles.GainUpY.Enable          = 'On';
                handles.ShiftDown.Enable        = 'On';
                handles.ShiftUp.Enable          = 'On';
                handles.ShiftLeft.Enable        = 'On';
                handles.ShiftRight.Enable       = 'On';
                handles.ShowBackground.Enable   = 'On';
                handles.ShowBlack.Enable        = 'On';
                handles.GiveJuice.Enable        = 'On';
                handles.StatusText.String='PLDAPS Paused';
            case 0 % run the next trial
                handles.OutputPanel.Visible     = 'On';
                handles.ParameterPanel.Visible  = 'On';
                handles.SettingsPanel.Visible   = 'On';
                handles.CloseGui.Visible        = 'On';
                handles.ControlsPanel.Visible   = 'On';
                handles.RunTrial.Enable         = 'Off';
                handles.FlipFrame.Enable        = 'Off';
                handles.PauseTrial.Enable       = 'On';
                handles.EyeTrackerPanel.Visible = 'On';
                handles.GiveJuice.Enable        = 'Off';
                handles.GainDownX.Enable        = 'Off';
                handles.GainDownY.Enable        = 'Off';
                handles.GainUpX.Enable          = 'Off';
                handles.GainUpY.Enable          = 'Off';
                handles.ShiftDown.Enable        = 'Off';
                handles.ShiftUp.Enable          = 'Off';
                handles.ShiftLeft.Enable        = 'Off';
                handles.ShiftRight.Enable       = 'Off';
                handles.StatusText.String='Trial Complete. Press P to pause';
        end
        
        ah=handles.EyeTrace;
%         eyeRad=ah.UserData;
        
%         axis(ah,[-eyeRad eyeRad -eyeRad eyeRad]);
%         
%         
%         plot(ah,eyeRad*[-1,1],[0,0],'--','Color',0.5*ones([1,3])); hold(ah,'all');
%         plot(ah,[0 0],eyeRad*[-1,1],'--','Color',0.5*ones([1,3]));

        handles.A.eyexy=getEye(p);
        handles.A.rawxy=getRaw(p);
        handles.A.hplot=plot(ah, handles.A.eyexy(1,:), handles.A.eyexy(2,:), '.');
        grid(ah, 'on')
        guidata(hObj, handles)
        drawnow
        hold(ah, 'off');


%         set(ah,'ButtonDownFcn',@(hObject,eventdata)MarmoView('EyeTrace_ButtonDownFcn',hObject,eventdata,handles));
%         % Same for the eye radius
%         set(ah,'UserData',eyeRad);

        

end

function eye=getRaw(p)
% get eye position in pixels
if p.trial.eyelink.use
    eyeIdx=p.trial.eyelink.eyeIdx;
    if p.trial.eyelink.useRawData
        eyeIdx=eyeIdx - 10; %the raw data is 10 fields prior to calibrated data
    end
    eye = p.trial.eyelink.samples(eyeIdx+[13 15],1:50:p.trial.eyelink.sampleNum);
else
    eye=[p.trial.mouse.cursorSamples(1,:)-p.trial.display.ctr(1); p.trial.mouse.cursorSamples(2,:)-p.trial.display.ctr(2)];
end

function eye=getEye(p)

% get eye position in pixels
if p.trial.eyelink.use
    eyeIdx=p.trial.eyelink.eyeIdx;
    if p.trial.eyelink.useRawData
        eyeIdx=eyeIdx - 10; %the raw data is 10 fields prior to calibrated data
    end
    eye = p.trial.eyelink.samples(eyeIdx+[13 15],1:50:p.trial.eyelink.sampleNum);
    
    if ~isempty(p.trial.eyelink.calibration_matrix)
        eye = p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)*[eye; ones(1,size(eye,2))];
    end
else
    eye=[p.trial.mouse.cursorSamples(1,:)-p.trial.display.ctr(1); p.trial.mouse.cursorSamples(2,:)-p.trial.display.ctr(2)];
end

% map from pixels to degrees
eye=pds.px2deg(eye, p.trial.display.viewdist, p.trial.display.px2w);
eye=bsxfun(@times, eye, [1; -1]);
