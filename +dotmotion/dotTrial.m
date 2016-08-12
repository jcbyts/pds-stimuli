function p=dotTrial(p,state, sn)
% simple dot motion trial
%
% 09.08.2016 Jacob L. Yates <jacoby8s@gmail.com>

if nargin<3
    sn='stimulus';
end

pldapsDefaultTrialFunction(p,state)

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        checkFixation(p, sn)
        checkMotionStates(p,sn)
        checkTarget(p,sn)
        
    case p.trial.pldaps.trialStates.trialSetup
        
        setupMotion(p,sn)
        setupFixation(p,sn)
        setupTargets(p,sn)
        setupReward(p, sn)
        
        p.trial.(sn).state=p.trial.(sn).states.START;
        p.trial.(sn).choiceTheta=nan;
        
    case p.trial.pldaps.trialStates.frameDraw
        % draw fixation
        p.trial.(sn).hFix.drawFixation
        
        % draw motion(s)
        for kMotion=1:numel(p.trial.(sn).motions)
            p.trial.(sn).(p.trial.(sn).motions{kMotion}).draw
        end
        
        % draw targets
        for kTarg=1:numel(p.trial.(sn).targets)
            p.trial.(sn).(p.trial.(sn).targets{kTarg}).draw
        end
        
%         % draw framerate
%         dataInds=max(round(p.trial.iFrame-3/p.trial.display.ifi),1):p.trial.iFrame-1;
%         time=dataInds*1000*p.trial.display.ifi;
%         
%         time2=time(2:end);
%         p.trial.sf(1).xlims=[max([min(time) 0]) max([time2 3000])];
%         opticflow.screenPlot(p.trial.sf(1), p.trial.sf(1).xlims, [p.trial.display.ifi p.trial.display.ifi], p.trial.display.clut.hBlack, '-');
%         opticflow.screenPlot(p.trial.sf(1), time2, diff(p.trial.timing.flipTimes(1,dataInds)), p.trial.display.clut.hRed, '.');
        
end

end

function setupTargets(p,sn)

switch p.trial.(sn).targetType
    case 'annulus'
        targRadPx=mean(pds.deg2px(p.trial.(sn).targetRadius, p.trial.display.viewdist, p.trial.display.w2px));
        targSzPx=mean(pds.deg2px(p.trial.(sn).targetSize, p.trial.display.viewdist, p.trial.display.w2px));
        targWinPx=mean(pds.deg2px(p.trial.(sn).targetWinSize, p.trial.display.viewdist, p.trial.display.w2px));
        
        n=numel(p.trial.(sn).conds.directions);
        p.trial.(sn).targets=cell(n,1);
        
        for kTarg=1:n
            p.trial.(sn).targets{kTarg}=sprintf('hTarg%d', p.trial.(sn).conds.directions(kTarg));
            
            p.trial.(sn).(p.trial.(sn).targets{kTarg})=stimuli.targetAnnulus(p.trial.display.overlayptr, ...
                'radius', targRadPx, ...
                'size', targSzPx, ...
                'winSize', targWinPx, ...
                'position', p.trial.display.ctr(1:2), ...
                'thetaSpan', p.trial.(sn).conds.directions(kTarg)+[-10 10], ...
                'colour', p.trial.display.clut.bg, ...
                'winColour', p.trial.display.clut.bg);
            
            p.trial.(sn).(p.trial.(sn).targets{kTarg}).beforeTrial;
        end
        
end

p.trial.(sn).showTargets=false;

end

function setupFixation(p,sn)
p.trial.(sn).hFix=stimuli.fixation(p.trial.display.overlayptr, ...
    'centreSize', p.trial.(sn).fixDotW/2, ...
    'surroundSize', p.trial.(sn).fixDotW, ...
    'position', p.trial.display.ctr(1:2)+pds.deg2px(p.trial.(sn).fixDotXY(:), p.trial.display.viewdist, p.trial.display.w2px, true)', ...
    'fixType', 2, ...
    'winType', 2, ...
    'centreColour', p.trial.display.clut.bg, ...
    'surroundColour', p.trial.display.clut.bg, ...
    'winColour', p.trial.display.clut.bg);
end

function setupReward(p,sn)
nMotions=numel(p.trial.(sn).motions);
maxReward=1;
p.trial.(sn).reward=repmat(struct('position', [], 'fun', []), nMotions,1);
for kMotion=1:nMotions
    theta=p.trial.(sn).(p.trial.(sn).motions{kMotion}).direction;
    radPx=mean(pds.deg2px(p.trial.(sn).targetRadius, p.trial.display.viewdist, p.trial.display.w2px));
    [x,y]=pol2cart(theta, radPx);
    p.trial.(sn).reward(kMotion).position=p.trial.(sn).hFix.position+[x y];
    p.trial.(sn).reward(kMotion).fun=@(x) vonMisesReward(x-p.trial.(sn).hFix.position, [maxReward theta/180*pi p.trial.(sn).rewardBandwidth]);
end

end

function setupMotion(p,sn)
fnames=fieldnames(p.trial.(sn));
motionFields=fnames(cellfun(@(x) any(strfind(x, 'motion')), fnames));
p.trial.(sn).showMotion=false;
p.trial.(sn).motions=cell(numel(motionFields),1);

for kMotion=1:numel(motionFields)
    thisMotion=p.trial.(sn).(motionFields{kMotion});
    thisHandle=['h' motionFields{kMotion}];
    p.trial.(sn).motions{kMotion}=thisHandle;
    switch thisMotion.type
        case 'dots'
            dotRadPx=mean(pds.deg2px(thisMotion.radius, p.trial.display.viewdist, p.trial.display.w2px));
            dotPosPx=p.trial.display.ctr(1:2)+pds.deg2px(thisMotion.position', p.trial.display.viewdist, p.trial.display.w2px)';
            dotSizPx=mean(pds.deg2px(thisMotion.size, p.trial.display.viewdist, p.trial.display.w2px));
            numDots=round(thisMotion.density*pi*thisMotion.radius^2/p.trial.display.frate);
            trialSpeed=mean(pds.deg2px(15, p.trial.display.viewdist, p.trial.display.w2px))/p.trial.display.frate;
            n=8;
            trialDirection=mod(round((rand()*360)/(360/n))*(360/n),360);
            
            p.trial.(sn).(thisHandle)=stimuli.dots(p.trial.display.ptr, ...
                'size', dotSizPx, ...
                'speed', trialSpeed, ... %FIX ME
                'direction', trialDirection, ... %FIX ME
                'numDots', numDots, ...
                'coherence', thisMotion.coherence, ...
                'mode', 1, ...
                'dist', 1, ...
                'bandwdth', thisMotion.bandwidth, ...
                'lifetime', thisMotion.lifetime, ...
                'maxRadius', dotRadPx, ...
                'position', dotPosPx);
            
            p.trial.(sn).(thisHandle).beforeTrial;
            p.trial.(sn).(p.trial.(sn).motions{kMotion}).visible=false;
            
    end
end

end

function checkTarget(p,sn)
currentEye=[p.trial.eyeX p.trial.eyeY];
gracePeriod=10;

if p.trial.iFrame > (p.trial.(sn).frameFpEntered + p.trial.(sn).targOnset)
    targetsOn(p,sn)
end

if p.trial.iFrame > (p.trial.(sn).frameTargetOn + p.trial.(sn).targDuration)
    targetsOff(p,sn)
end

switch p.trial.(sn).state
    case p.trial.(sn).states.CHOOSETARG
        for kTarg=1:numel(p.trial.(sn).targets)
            p.trial.(sn).(p.trial.(sn).targets{kTarg}).isheld(currentEye);
            if p.trial.(sn).(p.trial.(sn).targets{kTarg}).held>0
                p.trial.(sn).(p.trial.(sn).targets{kTarg}).colour=p.trial.display.clut.ltgray_green;
                p.trial.(sn).(p.trial.(sn).targets{kTarg}).winColour=p.trial.display.clut.bg_green;
                eyeXY=currentEye-p.trial.(sn).hFix.position;
                if p.trial.(sn).(p.trial.(sn).targets{kTarg}).held > gracePeriod
                    p.trial.(sn).choiceTheta=cart2pol(eyeXY(1),eyeXY(2));
                    choseTarg(p,sn)
                end
            end
        end
        
end


end

% function checkReward(p,sn)
%     p.trial.(sn).choiceTheta
%
% end

function choseTarg(p,sn)
p.trial.(sn).timeChoice=p.trial.ttime;
%     checkReward(p,sn)
p.trial.(sn).state=p.trial.(sn).states.TRIALCOMPLETE;
p.trial.pldaps.goodtrial=true;
p.trial.flagNextTrial=true;
end


function targetsOn(p,sn)
if ~p.trial.(sn).showTargets
    for kTarg=1:numel(p.trial.(sn).targets)
        p.trial.(sn).(p.trial.(sn).targets{kTarg}).colour=p.trial.display.clut.ltgray_red;
        p.trial.(sn).(p.trial.(sn).targets{kTarg}).winColour=p.trial.display.clut.bg_white;
    end
    p.trial.(sn).timeTargetOn=p.trial.ttime;
    p.trial.(sn).frameTargetOn=p.trial.iFrame;
    p.trial.(sn).showTargets=true;
end
end

function targetsOff(p,sn)
if p.trial.(sn).showTargets
    for kTarg=1:numel(p.trial.(sn).targets)
        p.trial.(sn).(p.trial.(sn).targets{kTarg}).colour=p.trial.display.clut.bg;
        p.trial.(sn).(p.trial.(sn).targets{kTarg}).winColour=p.trial.display.clut.bg;
    end
    p.trial.(sn).timeTargetOff=p.trial.ttime;
    p.trial.(sn).frameTargetOff=p.trial.iFrame;
    p.trial.(sn).showTargets=false;
end

end

function checkMotionStates(p, sn)
if p.trial.(sn).showMotion
    
    for kMotion=1:numel(p.trial.(sn).motions)
        p.trial.(sn).(p.trial.(sn).motions{kMotion}).visible=true;
        p.trial.(sn).(p.trial.(sn).motions{kMotion}).update;
    end
    
    if p.trial.iFrame > (p.trial.(sn).stimDur-p.trial.(sn).frameStimOn)
        motionOff(p,sn)
    end
end
end

function checkFixation(p, sn)
currentEye=[p.trial.eyeX p.trial.eyeY]; %p.trial.(sn).eyeXYs(1:2,p.trial.iFrame);
%     fprintf('checking: state ')
% check if fixation should be shown
switch p.trial.(sn).state
    case p.trial.(sn).states.START
        %             fprintf('START\n')
        
        % time to turn on fixation
        if p.trial.ttime > p.trial.(sn).preTrial
            fixOn(p,sn) % fixation point on
        end
        
    case p.trial.(sn).states.FPON
        %             fprintf('FPON\n')
        % is fixation held
        isheld=p.trial.(sn).hFix.isheld(currentEye);
        if isheld && p.trial.ttime < p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
            fixHold(p,sn)
        elseif p.trial.ttime > p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
            breakFix(p,sn)
        end
        
    case p.trial.(sn).states.FPHOLD
        %             fprintf('FPHOLD\n')
        % fixation controls motion
        if ~p.trial.(sn).showMotion && p.trial.iFrame > p.trial.(sn).frameFpEntered + p.trial.(sn).preStim
            motionOn(p,sn)
        end
        
        % is fixation held
        isheld=p.trial.(sn).hFix.isheld(currentEye);
        if isheld && p.trial.ttime < p.trial.(sn).maxFixHold + p.trial.(sn).timeFpEntered
            % do nothing
        elseif ~isheld && p.trial.ttime > p.trial.(sn).minFixHold + p.trial.(sn).timeFpEntered
            fixOff(p,sn)
            motionOff(p,sn)
        else % break fixation
            breakFix(p,sn)
        end
        
        
end

end

function breakFix(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.sColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.winColour=p.trial.display.clut.bg;
% PsychPortAudio('Start', p.trial.sound.breakfix)

p.trial.(sn).timeFpOff = p.trial.ttime;
p.trial.(sn).frameFpOff = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.BREAKFIX;
end

function fixOn(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.white;
p.trial.(sn).hFix.sColour = p.trial.display.clut.black;
p.trial.(sn).hFix.winColour=p.trial.display.clut.window;

p.trial.(sn).timeFpOn = p.trial.ttime;
p.trial.(sn).frameFpOn = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.FPON;
end

function fixHold(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.white;
p.trial.(sn).hFix.sColour = p.trial.display.clut.black;
p.trial.(sn).hFix.winColour=p.trial.display.clut.bg_green;

p.trial.(sn).timeFpEntered = p.trial.ttime;
p.trial.(sn).frameFpEntered = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.FPHOLD;
end

function fixOff(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.sColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.winColour=p.trial.display.clut.bg;

p.trial.(sn).timeFpOff = p.trial.ttime;
p.trial.(sn).frameFpOff = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.CHOOSETARG;
end

function motionOn(p,sn)
if ~p.trial.(sn).showMotion
    p.trial.(sn).showMotion=true;
    p.trial.(sn).timeStimOn=p.trial.ttime;
    p.trial.(sn).frameStimOn=p.trial.iFrame;
end
end

function motionOff(p,sn)
if p.trial.(sn).showMotion
    p.trial.(sn).showMotion=false;
    p.trial.(sn).timeStimOff=p.trial.ttime;
    p.trial.(sn).frameStimOff=p.trial.iFrame;
end
end

function y = vonMisesReward(xy, p)

th=pol2car(xy);
y=vonMises(p, th);
end

function y = vonMises(p,x)
% VONMISES The Von Mises function.
%  Y = VONMISES(P,X) calculates the von Mises function defined by the
%  parameter vector P, at locations X (expressed in deg.).
%
%  The von Mises function is defined as:
%
%       y = A * exp(k * (cos((pi/180)*(x-u))-1))
%
%     where A is the maximum amplitude
%           u is the mean (i.e., the position of the peak)
%           k is a measure of the concentration of the distribution
%                around the peak
%
%     the parameter vector p is defined as
%
%       p = [A, u, k]

assert(isvector(x),'argument x is not a vector!');

y = zeros([size(p,1),length(x)]);
for ii = 1:size(p,1),
    y(ii,:) = p(ii,1) .* exp(p(ii,3)*(cos((pi/180)*(x - p(ii,2)))-1));
end
end
