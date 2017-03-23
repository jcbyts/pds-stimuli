function updateGUI(p,sn)

% hObj = stimuli.fixflash.fixFlashPlot(1);
hObj = p.functionHandles.fixFlashPlot;
figure(hObj)
handles = guidata(hObj);

if nargin < 3
    sn = 'stimulus';
end
            
outcomes = cellfun(@(x) x.(sn).hTrial.error, p.data);
errs = [0 1 2];
n = numel(errs);
num = zeros(n,1);
for i = 1:n
    num(i) = sum(outcomes == errs(i));
end


handles.plots.outcomeBar.YData = num;
handles.plots.holdDurHist.Data = cellfun(@(x) x.(sn).hTrial.fixDuration, p.data);
handles.plots.holdDurHist.BinMethod = 'auto';
handles.plots.fixScatter.XData = cellfun(@(x) x.stimulus.hTrial.holdXY(1), p.data);
handles.plots.fixScatter.YData = cellfun(@(x) x.stimulus.hTrial.holdXY(2), p.data);

guidata(hObj, handles)

drawnow