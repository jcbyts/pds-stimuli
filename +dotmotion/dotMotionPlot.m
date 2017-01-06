function dotMotionPlot(handles,eyeData,P),
% DOTMOTIONPLOT plot eye position from a trial of MarmoView's dot motion task.

% 14-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>

% FIXME: marmoview needs (at minimum) a class system for tasks and stimuli!

% states are as follows:
%
% 0 - wait for fixation
% 1 - fixation grace period
% 2 - hold fixation
% 3 - show stimulus
% 4 - hide stimulus/hold fixation
% 5 - choice
% 6 - hold choice
% 7 - inter-trial interval (aborted trial)
% 8 - inter-trial interval (complete trial)

ah = handles.EyeTrace;

dx = handles.A.dx;
dy = handles.A.dy;
c = handles.A.c;
% pixPerDeg = handles.S.pixPerDeg;

eyeRad = get(ah,'UserData'); % so the user can zoom the eye position axes...

if ~iscell(eyeData),
  [n,m] = size(eyeData);
  eyeData = mat2cell(eyeData,ones([1,n]),m); % cell array for looping...
end

% convert eye position from "gaze space" to deg. of visual
% angle... relative to the centre of the screen
xDeg = cellfun(@(x) (x(2) - c(1))/dx, eyeData);
yDeg = cellfun(@(x) (x(3) - c(2))/dy, eyeData);
yDeg = -1*yDeg;

state = cellfun(@(x) x(6), eyeData);

axes(ah); cla(ah); hold on;
h = arrayfun(@(x,y) plot(x,y,'o','Color',repmat(0.75,1,3),'MarkerSize',2),xDeg,yDeg,'UniformOutput',0);

idx = find(ismember(state,[1,2])); % states 1,2 = fixation
h(idx) = cellfun(@(x) set(x,'Color',repmat(0.5,1,3)),h(idx),'UniformOutput',0);
idx = find(ismember(state,3)); % state 3 = motion
h(idx) = cellfun(@(x) set(x,'Color','b'),h(idx),'UniformOutput',0);
idx = find(ismember(state,5)); % state 5 = response
h(idx) = cellfun(@(x) set(x,'Color','g'),h(idx),'UniformOutput',0);
idx = find(ismember(state,6)); % state 6 = hold choice
h(idx) = cellfun(@(x) set(x,'Color','r'),h(idx),'UniformOutput',0);
        
% plot(h,0,0,'+k','LineWidth',2);
% set(h,'NextPlot','Add');
axis(ah,[-eyeRad eyeRad -eyeRad eyeRad]);
 
plot(ah,eyeRad*[-1,1],[0,0],'--','Color',0.5*ones([1,3]));
plot(ah,[0 0],eyeRad*[-1,1],'--','Color',0.5*ones([1,3]));

% show fixation window
r = P.fixWinRadius; % deg.
th = [0:0.02:1]*(2*pi);
[x,y] = pol2cart(th,r);
plot(ah,x,y,'k--');

% show stimulus aperture
r = P.stimWinRadius; % deg
[x,y] = pol2cart(th,r);
plot(ah,x+P.xDeg,y+P.yDeg,'--','Color',0.8*ones([1,3]));

% % show choice aperture... how? I need A.direction!
% r = P.respTargetRadius; % deg.
% [x,y] = pol2cart(th,r);
% r = P.stimWinRadius;
% th = 
% plot(ah,x+P.xDeg,y+P.yDeg,'--','Color',0.8*ones([1,3]));

hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THESE FINAL LINES SHOULD BE INCLUDED IN EVERY PROTOCOL PLOT FUNCTION TO
% MAINTAIN THE BUTTONDOWN FUNCTION TO ZOOM ON LEFT CLICK, OUT ON RIGHT
% This ensures the ButtonDownFcn is not erased with the new plots
%
% SC: are you kidding me?!
set(ah,'ButtonDownFcn',@(hObject,eventdata)MarmoView('EyeTrace_ButtonDownFcn',hObject,eventdata,handles));
% Same for the eye radius
set(ah,'UserData',eyeRad);
