function updateGUI(p,sn)

% hObj = stimuli.fixflash.fixFlashPlot(1);
hObj = p.functionHandles.fixFlashPlot;
figure(hObj)
handles = guidata(hObj);

if nargin < 3
    sn = 'stimulus';
end
            
outcomes = [cellfun(@(x) x.(sn).hTrial.error, p.data) p.trial.(sn).hTrial.error];
errs = [0 1 2];
n = numel(errs);
num = zeros(n,1);
for i = 1:n
    num(i) = sum(outcomes == errs(i));
end


handles.plots.outcomeBar.YData = num;

% TODO: This is a hack for the weird n=30 bug
tmp = [cellfun(@(x) x.(sn).hTrial.holdDuration, p.data) p.trial.stimulus.hTrial.holdDuration];
% assert(all(tmp<10), 'why are hold durations longer thatn 10s!?')
handles.plots.holdDurHist.Data = tmp(tmp<10);
handles.text.holdTitle.String = sprintf('Hold Duration (%02.2f, %02.2f, %02.2f)', min(handles.plots.holdDurHist.Data(outcomes==0)), mean(handles.plots.holdDurHist.Data(outcomes==0)), max(handles.plots.holdDurHist.Data));
handles.plots.holdDurHist.BinMethod = 'auto';
handles.plots.holdDurHist.NumBins = 30;
handles.plots.textOutcome0.Position = [handles.plots.outcomeBar.XData(1) handles.plots.outcomeBar.YData(1) 0];
handles.plots.textOutcome0.String   = num2str(handles.plots.outcomeBar.YData(1));

handles.plots.textOutcome1.Position = [handles.plots.outcomeBar.XData(2) handles.plots.outcomeBar.YData(2) 0];
handles.plots.textOutcome1.String   = num2str(handles.plots.outcomeBar.YData(2));

handles.plots.textOutcome2.Position = [handles.plots.outcomeBar.XData(3) handles.plots.outcomeBar.YData(3) 0];
handles.plots.textOutcome2.String   = num2str(handles.plots.outcomeBar.YData(3));

handles.plots.fixScatter.XData = [cellfun(@(x) x.stimulus.hTrial.holdXY(1), p.data) p.trial.stimulus.hTrial.holdXY(1)];
handles.plots.fixScatter.YData = [cellfun(@(x) x.stimulus.hTrial.holdXY(2), p.data) p.trial.stimulus.hTrial.holdXY(2)];

handles.plots.staircaseMin.XData = 1:p.trial.pldaps.iTrial;
handles.plots.staircaseMax.XData = 1:p.trial.pldaps.iTrial;
tmp1 = [cellfun(@(x) x.(sn).hTrial.fixDuration, p.data) p.trial.(sn).minFixDuration];
tmp1(tmp1 > 10) = nan;
handles.plots.staircaseMin.YData = tmp1;
tmp2 = [cellfun(@(x) x.(sn).hTrial.holdDuration, p.data) p.trial.(sn).hTrial.holdDuration];
tmp2(tmp2 > 10) = nan;
handles.plots.staircaseMax.YData = tmp2;

if p.trial.eyelink.use
    if p.trial.eyelink.useRawData
        
        switch p.trial.eyelink.eyeIdx
            case 1
                leye=strcmp(p.trial.eyelink.sampleIds, 'LeftEyeRawX');
                reye=strcmp(p.trial.eyelink.sampleIds, 'LeftEyeRawY');
                
                time  = p.trial.eyelink.samples(1,:)/1e3 - p.trial.timing.eyelinkStartTime(2);
                eyexy = p.trial.eyelink.samples(leye | reye, :);
            case 2
                leye=strcmp(p.trial.eyelink.sampleIds, 'RightEyeRawX');
                reye=strcmp(p.trial.eyelink.sampleIds, 'RightEyeRawY');
                
                time  = p.trial.eyelink.samples(1,:)/1e3 - p.trial.timing.eyelinkStartTime(2);
                eyexy = p.trial.eyelink.samples(leye | reye, :);
        end
        
        eyexy = p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)*[eyexy; ones(1,numel(time))];
        
    else
        
        switch p.trial.eyelink.eyeIdx
            case 1
                leye=strcmp(p.trial.eyelink.sampleIds, 'LeftEyeX');
                reye=strcmp(p.trial.eyelink.sampleIds, 'LeftEyeY');
                
                time  = p.trial.eyelink.samples(1,:)/1e3 - p.trial.timing.eyelinkStartTime(2);
                eyexy = p.trial.eyelink.samples(leye | reye, :);
            case 2
                leye=strcmp(p.trial.eyelink.sampleIds, 'RightEyeX');
                reye=strcmp(p.trial.eyelink.sampleIds, 'RightEyeY');
                
                time  = p.trial.eyelink.samples(1,:)/1e3 - p.trial.timing.eyelinkStartTime(2);
                eyexy = p.trial.eyelink.samples(leye | reye, :);
                
        end
        
    end
    
    fpon = p.trial.stimulus.hTrial.getTxTime(0);
    fpentered = p.trial.stimulus.hTrial.getTxTime(1);
    fphold    = p.trial.stimulus.hTrial.getTxTime(2);
    breakfix  = p.trial.stimulus.hTrial.getTxTime(7);
    iti       = p.trial.stimulus.hTrial.getTxTime(8);
    
    eyexy = bsxfun(@minus, eyexy, p.trial.stimulus.hFix(1).position');
	eyexy = pds.px2deg(eyexy, p.trial.display.viewdist, p.trial.display.px2w);
    
    ax =handles.LastTrialPlot;
    hold(ax, 'off');
    h(1)=plot(ax, time, eyexy(1,:), 'k');
    hold(ax, 'on');
    h(2)=plot(ax, time, eyexy(2,:), 'Color', .7*[1 1 1]);
    h(3)=plot(ax, [-10 10], p.trial.stimulus.fixWinRadius*[1 1], ':k');
    plot(ax, [-10 10], -p.trial.stimulus.fixWinRadius*[1 1], ':k')
    xlim(ax, [-.1 max(time)])
    yd = [-5 5];
    ylim(ax, yd)
    h(4)=plot(ax, [fpon fpon], yd, '-');
    h(5)=plot(ax, [fpentered fpentered], yd, '-');
    h(6)=plot(ax, [fphold fphold], yd, '-');
    
    legstr = {'Eye X', 'Eye Y', 'Fix Win', 'FP on', 'FP ent', 'FP hold'};
    if ~isnan(breakfix)
        h(7)=plot(ax, [breakfix breakfix], yd, '-r');
        legstr = [legstr {'breakfix'}];
    else
        h(7)=plot(ax, [iti iti], yd, '-b');
        legstr = [legstr {'face'}];
    end
    legend(ax, h, legstr, 'Location', 'EastOutside')
    ylabel(ax, 'degrees')
    xlabel(ax, 'Time (seconds')
    title(ax, 'Last Trial')
end

guidata(hObj, handles)

drawnow