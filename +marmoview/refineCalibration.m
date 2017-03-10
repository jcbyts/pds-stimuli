function c = refineCalibration(p)

if ~isa(p, 'pldaps')
    calledFromMarmoView = true;
    p = p.p;
else
    calledFromMarmoView = false;
end

% --- Parameters
maxFrames = 100e3;
winRadius=50;
targDur=500;
targHold=50;
targFlash=20;
genNew=true;
iFrame=1;
ctr=p.trial.display.ctr(1:2);
dotSize=15;

% --- reset keyboard queue and start a new one
%  KbQueueRelease();
%  KbQueueCreate();
%  KbQueueStart();


% --- Check if using eyelink for eye position
if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos && p.trial.eyelink.useRawData
    if isempty(p.trial.eyelink.calibration_matrix)
        m=getpref('marmoview_calibration');
        if isfield(m, p.trial.session.subject)
            p.trial.eyelink.calibration_matrix=permute(m.(p.trial.session.subject), [2 1 3]);
%             p.trial.eyelink.calibration_matrix=m.(p.trial.session.subject)';
        else
            cm=[1 0; 0 1; 0 0]';
            cm(:,:,2)=cm;
            p.trial.eyelink.calibration_matrix=cm; % assume default calibration
        end
        
        if numel(size(p.trial.eyelink.calibration_matrix))==2
            p.trial.eyelink.calibration_matrix(:,:,2) = p.trial.eyelink.calibration_matrix;
        end
    end
    c=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx);
else
    c = [];
    return
end
    

% initialize variables
rawEye  = nan(maxFrames,2);
cEye    = nan(maxFrames,2);

targXY = [];
eyeXY  = [];
rawXY  = [];

state=0; % wait for fixation
state0Entered=0;

% get marmoset face textures
A=loadMarmosetTextures(p);

Screen('TextSize', p.trial.display.overlayptr, 36);
Screen('Preference', 'TextAntiAliasing', 0);   

while iFrame < maxFrames
    
    [~, firstPressQ]=KbQueueCheck(); % fast
    if firstPressQ(p.trial.keyboard.codes.escKey)
        break;
    elseif firstPressQ(p.trial.keyboard.codes.sKey)
        saveCalibrationAsRigPref(p, c')
    end
    
    % clear overlay pointer
    Screen('FillRect', p.trial.display.overlayptr,0);
    
    % get eye position
    [eye, raw]=getEye(p);
    
    % store eye
    rawEye(iFrame,:)=raw;
    currentEyeXY = c*[raw; 1];
    cEye(iFrame,:)=eye;
    
    % generate new target
   if genNew
       % new target location
       xy=randn(1,2)*100+ctr;
       
       % reward face
       texid=A.Marmotex(randi(numel(A.Marmotex), 1));
       dstRect=CenterRectOnPoint([0 0 winRadius winRadius]*2, xy(1), xy(2));
       
       genNew=false;
   end
    
   % calculate distance from target
   r1=norm(currentEyeXY'-xy); % for current calibration matrix
   r2=norm(eye' - xy); % for saved calibration matrix
   % take minimum
   r = min(r1, r2);
   isHeld = r < winRadius;
   
%    fprintf('state %d\n', state)
   %-----------------------------------------------------------------------
   % State machine
   switch state
       
       case 0 % wait for fixation
           
           showFace=false;
           
           stateCtr=iFrame-state0Entered;
           
           if mod(iFrame,targFlash)<10
               dotColor=p.trial.display.clut.bg;
           else
               dotColor=p.trial.display.clut.targetnull;
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
           
           dotColor=p.trial.display.clut.targetgood;
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
           dotColor=p.trial.display.clut.bg;
           if stateCtr==1
            pds.behavior.reward.give(p);
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
           dotColor=p.trial.display.clut.bg;
           
           stateCtr=iFrame-state3Entered;
            if stateCtr > 50
               state=0; % reset
               state0Entered=iFrame;
               genNew=true;
           end
           
   end % states
           
       
   
   
   
   % draw target
   Screen('DrawDots', p.trial.display.overlayptr, xy, dotSize, dotColor, [], 2);
   
   eyeix=(iFrame-20):iFrame;
   eyeix(eyeix<1)=[];
   % draw eye position
   Screen('DrawDots', p.trial.display.overlayptr, currentEyeXY', 4, p.trial.display.clut.eyepos, [], 0);
        
   % draw raw signal
   Screen('DrawDots', p.trial.display.overlayptr, cEye(eyeix,:)', 4, p.trial.display.clut.bg_green, [], 0);
   % window
   Screen('DrawArc',p.trial.display.overlayptr,p.trial.display.clut.bg_green,dstRect,0,360)
   % draw reward face
   if showFace
       Screen('DrawTexture', p.trial.display.ptr, texid, [], dstRect);
   end
   
   % Draw instructions
   DrawFormattedText(p.trial.display.overlayptr, ...
       'Press esc to exit. Press S to save calibration', ...
       'center', 250, p.trial.display.clut.bg_white); 
   
   Screen('Flip', p.trial.display.ptr, 0);
   
   iFrame = iFrame+1;
end

% clear overlay pointer
Screen('FillRect', p.trial.display.overlayptr,0);
Screen('Flip', p.trial.display.ptr, 0);

cleanupMarmosetTextures(A)

% --- Save the current eye calibration to rig preferences
function saveCalibrationAsRigPref(p,c)
subj=p.trial.session.subject;

% get previous calibration matrix
cm = getpref('marmoview_calibration', subj);

% update the calibration matrix depending on which eye is tracked
if isempty(cm)
    cm = c;
    cm(:,:,2) = c;
elseif p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
    cm(:,:,p.trial.eyelink.eyeIdx) = c;
end

setpref('marmoview_calibration', subj, cm)
disp('saved new calibration matrix.')


% --- get recent eye position values
function [eye, raw]=getEye(p)
if p.trial.eyelink.use
    sample=Eyelink('NewestFloatSample');
    eyeIdx=p.trial.eyelink.eyeIdx;
    if p.trial.eyelink.useRawData
        raw=[sample.px(eyeIdx); sample.py(eyeIdx)];
        eye=p.trial.eyelink.calibration_matrix(:,:,eyeIdx)*[raw; 1];
    else
        eye=[sample.gx(eyeIdx); sample.gy(eyeIdx)];
        raw=[sample.px(eyeIdx); sample.py(eyeIdx)];
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
opts=optimset('maxIter', 50, 'display', 'off');
chat=fmincon(fun, c,[],[],[],[],[],[],[],opts);
errNewCalibMat   = norm(chat*X' - targXY');
errOldCalibMat   = norm(c*X' - targXY');
% errSavedCalibMat = norm(eyeXY - targXY);

if errNewCalibMat < errOldCalibMat 
   c=chat;
   fprintf('calibration matrix refined\n')% errNewCalibMat-errOldCalibMat
end

% --- cleanup marmoset textures
function cleanupMarmosetTextures(A)
if isfield(A, 'Marmotex')
    for i=1:numel(A.Marmotex)
        Screen('Close', A.Marmotex(i));
    end
    A=rmfield(A, 'Marmotex');
    A=rmfield(A, 'MarmotexSize');
end

% --- load up marmoset face textures
function A=loadMarmosetTextures(p)
MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
MFL = struct2cell(MFL);
MFL = MFL([7,10,13,17:20,24,25,27]); % these faces seem most centered

for id = 1:length(MFL),
  img = MFL{id};
  
  sz = size(img);
  % gaussian envelope...
  x = [1:sz(1)]-sz(1)/2; y = [1:sz(2)]-sz(2)/2;
  [x,y] = meshgrid(x,y);
  g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
  g = g - min(g(:));
  g = g./max(g(:));
  img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
    
  A.Marmotex(id)=Screen('MakeTexture',p.trial.display.ptr,img);
  A.MarmotexSize(1,id)=sz(1);
  A.MarmotexSize(2,id)=sz(2);
end