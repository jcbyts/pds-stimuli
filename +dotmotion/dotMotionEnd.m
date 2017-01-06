function [D,P,A] = dotMotionEnd(D,A,P,S),
% DOTMOTIONEND Tidy up after a trial of MarmoView's dot motion task.
%
% Returns D, P and A structures with fields:
%
%   D.fixDuration - the initial fixation duration required to initiate the trial
%   D.choiceTargetDelay - delay from motion onset to presentation of the choice target(s)
%   D.rngSettings - the state of the random number generator on this trial
%   D.direction - motion direction on this trial
%   D.error - the outcome of this trial (0 = complete)
%   D.choice - the choice direction
%   D.eyeData - gaze position data (gaze space) 
%   D.C - eye calibration parameters

% 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>

% FIXME: marmoview needs (at minimum) a class system for tasks and stimuli!

% grrr! copy data to be saved to the D structure...
D.fixDuration(A.j) = A.fixDuration;
D.cueDelay(A.j) = A.cueDelay;
D.rngSettings(A.j) = A.rngSettings;
D.direction(A.j) = A.direction; % deg.

D.error(A.j) = A.error;

D.choice(A.j) = A.choice; % deg.

D.eyeData{A.j} = A.eyeData;

% NOTE THAT THS RECORDS FINAL CALIBRATION VALUES OF THE TRIAL, WHICH CAN
% BE CHANGES MID-TRIAL. THEREFORE, ADJUST CALIBRATION MID-TRIAL SPARINGLY.
% BETTER TO PAUSE, ADJUST BASED ON THE EYE TRACE PLOT AND CONTINUE.
D.C(A.j).c = A.c;
D.C(A.j).dx = A.dx;
D.C(A.j).dy = A.dy;

%
% plot stuff...
%

% colours..
cmap(1,:) = [0.0,0.7,0.3]; % predictive
cmap(2,:) = [0.0,0.3,0.7]; % cued

%
% trial outcomes/errors
%
axes(A.DataPlot1);
errors = [0:6];
n = histc(D.error,errors);
h = bar(errors,n);
set(h,'EdgeColor',ones([1,3]),'FaceColor',0.75*ones([1,3]));
xlim([-0.5, max(errors)+0.5]);
title(A.DataPlot1,'Trial outcomes');
ylabel(A.DataPlot1,'Trials');

% show the number
y = 0.15*max(ylim);

h = [];
for ii = 1:size(errors,2),
  axes(A.DataPlot1);
  h(ii) = text(errors(ii),y,sprintf('%i',n(ii)),'HorizontalAlignment','Center');
end
% set(h(n > 2*y),'Color','w');

% plot predictive and cued trials separately
trialIds = find(D.error == 0); % complete trials
t0 = cellfun(@(x) x(find(ismember(x(:,end),3),1)), D.eyeData(trialIds));
t1 = cellfun(@(x) x(find(ismember(x(:,end),6),1)), D.eyeData(trialIds));
dt = t1-t0;

pidx = find(dt < D.cueDelay(trialIds)); % predictive trials
cidx = find(dt >= D.cueDelay(trialIds)); % cued trials

%
% show error (choice - true direction)
%
axes(A.DataPlot2);

err = mod(D.choice-D.direction+180,360)-180; % all trials

binsz = 2*180/16;
      
edges = [-180.0:binsz:180.0+binsz]; % deg.

n = zeros([2,length(edges)]);
if ~isempty(pidx),
  n(1,:) = histc(err(trialIds(pidx)),edges); % predictive
  n(1,:) = n(1,:)./sum(n(1,:));
end
if ~isempty(cidx),
  n(2,:) = histc(err(trialIds(cidx)),edges); % cued
  n(2,:) = n(2,:)./sum(n(2,:));
end    

h = bar(edges,n',1.0);

set(h(1),'FaceColor',cmap(1,:)); % predictive
set(h(2),'FaceColor',cmap(2,:)); % cued

set(h,'EdgeColor',ones([1,3]));

hold on

y = max(get(gca,'YLim'));
h = text(-170,0.9*y,sprintf('n = %i',length(pidx)));
h(2) = text(-170,0.75*y,sprintf('n = %i',length(cidx)));
set(h(1),'Color',cmap(1,:));
set(h(2),'Color',cmap(2,:));

% plot reward schedule
h = plot(-180:180,0.9*y*(circshift(A.reward,180,2)./P.maxRewardCnt));
set(h,'Color',repmat(0.5,1,3));

hold off

xlim([-1 1]*180);
set(A.DataPlot2,'XTick',-180:90:180);

xlabel('Error (deg.)');
ylabel('Prop. trials');

%
% show choice vs true direction
%
axes(A.DataPlot3);

plot([0 360],[0 360],'k--');
hold on

if ~isempty(pidx),
  % predictive trials
  x = D.direction(trialIds(pidx));
  y = D.choice(trialIds(pidx));

  h = plot(x-5.0,y,'o','MarkerSize',4);

  conds = unique(x);
  ii = arrayfun(@(c) find(x == c),conds,'UniformOutput',0);
      
  mn = cellfun(@(jj) cmean(y(jj)'*(pi/180)),ii);
  mn = mod(mn*(180/pi),360); % mean for each condition

  h(2) = plot(mod(conds-5.0,360),mn,'d');

  set(h,'Color',cmap(1,:)); % predictive
  set(h(2),'MarkerFaceColor',cmap(1,:));
end

if ~isempty(cidx),
  % cued trials
  x = D.direction(trialIds(cidx));
  y = D.choice(trialIds(cidx));

  h = plot(x+5.0,y,'o','MarkerSize',4);

  conds = unique(x);
  ii = arrayfun(@(c) find(x == c),conds,'UniformOutput',0);
      
  mn = cellfun(@(jj) cmean(y(jj)'*(pi/180)),ii);
  mn = mod(mn*(180/pi),360); % mean for each condition

  h(2) = plot(mod(conds+5.0,360),mn,'d');

  set(h,'Color',cmap(2,:)); % cued
  set(h(2),'MarkerFaceColor',cmap(2,:));
end

% plot bonus schedule
h = plot(0:360,0.9*360*A.bonus./P.bonusRewardCnt);
set(h,'Color',repmat(0.5,1,3));

if 1,
  % highlight the last completed trial with a red circle...
  if D.error(A.j) == 0,
    if any(trialIds(pidx) == A.j),
      % predictive trial
      x = D.direction(A.j)-5.0;
    else,
      % cued trial
      x = D.direction(A.j)+5.0;
    end
    y = D.choice(A.j);
    plot(mod(x,360),y,'ro','MarkerSize',15);
  end
end

hold off

xlim([0 360]);
ylim([0 360]);

set(A.DataPlot3,'XTick',0:90:360);
set(A.DataPlot3,'YTick',0:90:360);

% axis square
% title(A.DataPlot3,'Choice vs True Direction');
xlabel('True direction (deg.)');
ylabel('Choice (deg.)');

% circular mean...
function mn = cmean(theta),
  mn = angle(nansum(exp(1i*theta(:))));
end

end % function
