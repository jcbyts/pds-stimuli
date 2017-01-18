function c = refineCalibration(handles)

maxFrames = 100e3;
winRadius=50;

targDur=500;
targHold=50;
targFlash=20;

genNew=true;

iFrame=1;

ctr=handles.p.trial.display.ctr(1:2);
dotSize=15;


c=handles.p.trial.eyelink.calibration_matrix;

% initialize variables
rawEye  = nan(maxFrames,2);
cEye    = nan(maxFrames,2);

targXY = [];
eyeXY  = [];
rawXY  = [];

state=0; % wait for fixation
state0Entered=0;

while ~KbCheck && iFrame < maxFrames
    
    % clear overlay pointer
    Screen('FillRect', handles.p.trial.display.overlayptr,0);
    
    % get eye position
    [eye, raw]=getEye(handles.p);
    
    % store eye
    rawEye(iFrame,:)=raw;
    currentEyeXY = c*[raw; 1];
    cEye(iFrame,:)=eye;
    
    % generate new target
   if genNew
       % new target location
       xy=randn(1,2)*100+ctr;
       
       % reward face
       texid=handles.A.Marmotex(randi(numel(handles.A.Marmotex), 1));
       dstRect=CenterRectOnPoint([0 0 winRadius winRadius]*2, xy(1), xy(2));
       
       genNew=false;
   end

   r=norm(currentEyeXY'-xy);
   isHeld = r < winRadius;
   
%    fprintf('state %d\n', state)
   %-----------------------------------------------------------------------
   % State machine
   switch state
       
       case 0 % wait for fixation
           
           showFace=false;
           
           stateCtr=iFrame-state0Entered;
           
           if mod(iFrame,targFlash)<10
               dotColor=handles.p.trial.display.clut.bg;
           else
               dotColor=handles.p.trial.display.clut.targetnull;
           end
           
           if isHeld % transition to next state
               state=1;
               state1Entered=iFrame;
           end
           
           if stateCtr > targDur
               state=3;
               state3Entered=iFrame;
           end
          
           
       case 1 % hold fixation
           
           showFace=false;
           
           dotColor=handles.p.trial.display.clut.targetgood;
           stateCtr=iFrame-state1Entered;
           
           if isHeld % holding fixation
               
               % wait for hold duration
               if stateCtr >= targHold
                   
                   % store target, eye
                   targXY=[targXY; xy];
                   eyeXY=[eyeXY; mean(cEye((iFrame-ceil(targHold/2)):iFrame,:))];
                   rawXY=[rawXY; mean(rawEye((iFrame-ceil(targHold/2)):iFrame,:))];
                   
                   % move to reward state
                   state=2;
                   state2Entered=iFrame;
               end
               
           else
               state=3;
               state3Entered=iFrame;
           end
           
           
       case 2 % reward
           
           % time in state
           stateCtr=iFrame-state2Entered;
           
           % hide target
           dotColor=handles.p.trial.display.clut.bg;
           if stateCtr==1
            pds.behavior.reward.give(handles.p);
           end
           
           showFace=true;
           
           if stateCtr > 40
               showFace=false;
           end
           
           if stateCtr > 50
               state=0; % reset
               state0Entered=iFrame;
               genNew=true;
               
               c=updateCalibrationMatrix(c, targXY, eyeXY, rawXY);
           end
           
       case 3 % break
           
           % hide target
           dotColor=handles.p.trial.display.clut.bg;
           
           stateCtr=iFrame-state3Entered;
            if stateCtr > 50
               state=0; % reset
               state0Entered=iFrame;
               genNew=true;
           end
           
   end % states
           
       
   
   
   
   % draw target
   Screen('DrawDots', handles.p.trial.display.overlayptr, xy, dotSize, dotColor, [], 2);
   
   eyeix=(iFrame-20):iFrame;
   eyeix(eyeix<1)=[];
   % draw eye position
   Screen('DrawDots', handles.p.trial.display.overlayptr, currentEyeXY', 4, handles.p.trial.display.clut.eyepos, [], 0);
        
   % draw raw signal
   Screen('DrawDots', handles.p.trial.display.overlayptr, cEye(eyeix,:)', 4, handles.p.trial.display.clut.greenbg, [], 0);
   % window
   Screen('DrawArc',handles.p.trial.display.overlayptr,handles.p.trial.display.clut.greenbg,dstRect,0,360)
   % draw reward face
   if showFace
       Screen('DrawTexture', handles.p.trial.display.ptr, texid, [], dstRect);
   end
   
   Screen('Flip', handles.p.trial.display.ptr, 0);
   
   iFrame = iFrame+1;
end

Screen('Flip', handles.p.trial.display.ptr, 0);


% --- get recent eye position values
function [eye, raw]=getEye(p)
if p.trial.eyelink.use
    sample=Eyelink('NewestFloatSample');
    eyeIdx=p.trial.eyelink.eyeIdx;
    if p.trial.eyelink.useRawData
        raw=[sample.px(eyeIdx); sample.py(eyeIdx)];
        eye=p.trial.eyelink.calibration_matrix*[raw; 1];
    else
        eye=[p.trial.eyelink.gx(eyeIdx); p.trial.eyelink.gy(eyeIdx)];
        raw=eye;
    end
else
    [x,y]=GetMouse;
    eye=[x; y];
    raw=eye;
end

% --- use regression to update the calibration matrix
function c=updateCalibrationMatrix(c, targXY, eyeXY, rawXY)

sz=size(targXY);
if sz(1) < 5
    return
end

assert(numel(targXY)==numel(eyeXY), 'eye position samples do not match targets')

X=[rawXY ones(sz(1),1)];


% chat=(X'*X)\(X'*targXY);
% chat=chat';

fun=@(c) norm(c*X' - targXY');
opts=optimset('maxIter', 50);
chat=fmincon(fun, c,[],[],[],[],[],[],[],opts);
a=norm(chat*X' - targXY');
b=norm(c*X' - targXY');

disp(a-b)
if a < b 
   c=chat;
   disp('calibration matrix refined')
end
