function p=marmoview_FaceCal(p,state,sn)
% MARMOVIEW FACE CALIBRATION
% simple manual eyetracker calibration

% this function will be called everytime PLDAPS updates time in the trial.
% Depending on the current state, different actions (defined below) happen
switch state
    
    % Main action happen here
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % check keyboard presses and act accordingly
        if any(p.trial.keyboard.firstPressQ)
            
            % is Ctrl held
            ctrlDown=isCtrlDown(p);
            
            % calibration matrix
            b=p.trial.(sn).b;
            [g,r,o]=calibrationMatrixToGains(b, p.trial.display.ctr(1:2));
            changedMatrix=false;
            gnstep=.01;
            offstep=50;
            
            % center the eye position
            if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.cKey)
                eye=getEye(p);
                o=-eye;
            end
            
            % decrease x offset (gain with ctrl down)
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Larrow)
                if  ctrlDown % gain
                    g(1) = g(1) - gnstep;
                else % offset
                    o(1) = o(1) + offstep;
                end
                changedMatrix=true;
            end
            
            % increase x offset (gain with ctrl down)
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Rarrow)
                if  ctrlDown % gain
                    g(1) = g(1) + gnstep;
                else % offset
                    o(1) = o(1) - offstep;
                end
                changedMatrix=true;
            end
            
            % decrease y offset (gain with ctrl down)
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Darrow)
                if  ctrlDown % gain
                    g(2) = g(2)-gnstep;
                else % offset
                    o(2) = o(2)-offstep;
                end
                changedMatrix=true;
            end
            
            % increase y offset (gain with ctrl down)
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Uarrow)
                if  ctrlDown % gain
                    g(2) = g(2) + gnstep;
                else % offset
                    o(2) = o(2) + offstep;
                end
                changedMatrix=true;
            end
            
            
            %copy current estimate current pldaps (rig prefs if ctrl down)
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.xKey)
                %copy current estimate to manual
                if  ~ctrlDown
                    overrideCurrentCalibrationMatrix(p)
                else %save as new rig pref
                    saveCalibrationAsRigPref(p)
                end
                changedMatrix=true;
            end
            
            if changedMatrix
                % convert back to calibration matrix
                p.trial.(sn).b = gainsToCalibrationMatrix(g,r,o,p.trial.display.ctr(1:2));
            end
%                 p.trial.(sn).clickedEyePos=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)*[p.trial.(sn).rawEye;ones(1,size(p.trial.(sn).rawEye,2))];
%             end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.rKey)
                p.trial.(sn).randomize=~p.trial.(sn).randomize;
            end
            
            %condition manipulation
            addCondition=0;
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.oneKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPoneKey)
                addCondition=ceil(numel(p.trial.stimulus.target)/2);
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.twoKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPtwoKey)
                addCondition=ceil(numel(p.trial.stimulus.target)/2);
                addCondition=[addCondition-1 addCondition];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.thrKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPthrKey)
                nTarg=numel(p.trial.stimulus.target);
                addCondition=ceil(nTarg/2);
                addCondition=[addCondition addCondition+1];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.forKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPforKey)
                nTarg=numel(p.trial.stimulus.target);
                addCondition=ceil(nTarg/2);
                addCondition=[addCondition-sqrt(nTarg) addCondition];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.fivKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPfivKey)
                nTarg=numel(p.trial.stimulus.target);
                addCondition=ceil(nTarg/2);
                addCondition=[addCondition addCondition+sqrt(nTarg)];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.sixKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPsixKey)
                nTarg=numel(p.trial.stimulus.target);
                addCondition=ceil(nTarg/2);
                addCondition=[addCondition-sqrt(nTarg) addCondition-1 addCondition addCondition+1 addCondition+sqrt(nTarg)];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.svnKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPsvnKey)
                nTarg=numel(p.trial.stimulus.target);
                sN=sqrt(nTarg);
                addCondition=[2 sN+1 nTarg-sN nTarg-1];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.eitKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPeitKey)
                nTarg=numel(p.trial.stimulus.target);
                sN=sqrt(nTarg);
                addCondition=[sN-1 2*sN nTarg-2*sN+1 nTarg-sN+2];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.ninKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPninKey)
                nTarg=numel(p.trial.stimulus.target);
                cN=ceil(nTarg/2);
                sN=sqrt(nTarg);
                addCondition=[cN-sN cN-2*sN cN-2 cN-1 cN cN+1 cN+2 cN+sN cN+2*sN];
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.zerKey) || p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.KPzerKey)
                addCondition=-1; % repeat current
            elseif p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.rKey)
                addCondition=100;
            end
            
            if addCondition~=0
                for kTarg=1:numel(p.trial.stimulus.target)
                    p.trial.stimulus.target(kTarg).motionstates.drawObjectNr=2;
                    p.trial.stimulus.target(kTarg).currentMotionState=1;
                    p.trial.stimulus.target((kTarg)).saveout(1:2,p.trial.stimulus.arrayIndex)=p.trial.stimulus.target(kTarg).currentXY;
                    p.trial.stimulus.target((kTarg)).saveout(3,p.trial.stimulus.arrayIndex)=p.trial.stimulus.target(kTarg).motionstates.drawObjectNr;
                    p.trial.stimulus.target((kTarg)).saveout(4,p.trial.stimulus.arrayIndex)=p.trial.iFrame;
                end
                
                if max(addCondition)>=1 && max(addCondition) <= numel(p.trial.stimulus.target)
                    for kTarg=1:numel(addCondition)
                        [p.trial.stimulus.target(addCondition(kTarg)).motionstates.drawObjectNr]=randi(numel(p.trial.stimulus.object)-2)+2;
                        if p.trial.(sn).randomize
                            p.trial.stimulus.target(addCondition(kTarg)).currentXY=randn(2,1)*10;
                        end
                        
                        p.trial.stimulus.target(addCondition(kTarg)).saveout(1:2,p.trial.stimulus.arrayIndex)=p.trial.stimulus.target(addCondition(kTarg)).currentXY;
                        p.trial.stimulus.target(addCondition(kTarg)).saveout(3,p.trial.stimulus.arrayIndex)=p.trial.stimulus.target(addCondition(kTarg)).motionstates.drawObjectNr;
                        p.trial.stimulus.target(addCondition(kTarg)).saveout(4,p.trial.stimulus.arrayIndex)=p.trial.iFrame;
                    end
                end
                
                p.trial.stimulus.arrayIndex=p.trial.stimulus.arrayIndex+1;
                %                     rep=1+4*ctrlDown; %ctrl+number: add it five times
                %                     if addCondition==-1
                %                         cond=p.conditions(p.trial.pldaps.iTrial);
                %                     else
                %                         % find condition
                %                         stimx=cellfun(@(x) x.stimulus.target(1).initialXY(1), p.conditions);
                %                         stimy=cellfun(@(x) x.stimulus.target(1).initialXY(2), p.conditions);
                %                         id=find((stimx + stimy*1000) == p.trial.(sn).uniqueStimId(addCondition), 1);
                %                         cond=p.conditions(id);
                %                     end
                %                     p.conditions = [p.conditions(1:p.trial.pldaps.iTrial); repmat(cond,rep,1); p.conditions(p.trial.pldaps.iTrial+1:end)];
            end
            
        end
        
    case p.trial.pldaps.trialStates.frameDraw
                
        %draw the eyepos from current live calibration
        eye=getEye(p);
        
        eye=p.trial.(sn).b'*[eye; ones(size(eye(1,:)))];
        
        Screen('Drawdots',  p.trial.display.overlayptr, eye, ...
            2, p.trial.display.clut.greenbg, [0 0],0);
        
        
    case p.trial.pldaps.trialStates.trialSetup
        
        if p.trial.pldaps.iTrial>1
            p.trial.(sn).clickedEyeStim = p.data{end}.(sn).clickedEyeStim;
            p.trial.(sn).clickedEyePos = p.data{end}.(sn).clickedEyePos;
            p.trial.(sn).rawEye = p.data{end}.(sn).rawEye;
            p.trial.(sn).stimPos = p.data{end}.(sn).stimPos;
            
            p.trial.(sn).b = p.data{end}.(sn).b;
            
            if p.trial.eyelink.use && isfield(p.data{end}.eyelink, 'calibration_matrix')
                p.trial.eyelink.calibration_matrix = p.data{end}.eyelink.calibration_matrix;
            end
        else
            p.trial.(sn).clickedEyePos=ones(2,0);
            p.trial.(sn).clickedEyeStim=ones(1,0);
            p.trial.(sn).rawEye=zeros(2,0);
            p.trial.(sn).stimPos=zeros(2,0);
            
            b=getCalibrationPref(p);           
            p.trial.(sn).b = b;
        end
        
        disp(p.trial.pldaps.iTrial)
        for kTarg=1:numel(p.trial.stimulus.target)
            p.trial.stimulus.target(kTarg).saveout=nan(4,20);
        end
        p.trial.stimulus.arrayIndex=1;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        for kTarg=1:numel(p.trial.stimulus.target)
            p.trial.stimulus.target(kTarg).saveout(:,isnan(p.trial.stimulus.target(kTarg).saveout(1,:)))=[];
        end
        
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        if ~isfield(p.trial.(sn),'drawStims')
            p.trial.(sn).drawStims = true;
        end
        if ~isfield(p.trial.(sn),'rewardOnMarker')
            p.trial.(sn).rewardOnMarker = true;
        end
        if ~isfield(p.trial.(sn),'refineCalibratrionFromWindow')
            p.trial.(sn).refineCalibratrionFromWindow = false;
        end
        
        if ~isfield(p.trial.(sn), 'randomize')
            p.trial.(sn).randomize=false;
        end
        
        if ~isfield(p.trial.(sn), 'eyeposMovAv')
            p.trial.(sn).eyeposMovAv = 10;
        end
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        stimx=cellfun(@(x) x.stimulus.target(1).initialXY(1), p.conditions);
        stimy=cellfun(@(x) x.stimulus.target(1).initialXY(2), p.conditions);
        p.trial.(sn).uniqueStimId=unique(stimx + stimy*1000);
        p.trial.(sn).uniqueStims=ones(2,length(p.trial.(sn).uniqueStimId));
        for i=1:length(p.trial.(sn).uniqueStimId)
            id=find((stimx + stimy*1000) == p.trial.(sn).uniqueStimId(i), 1);
            p.trial.(sn).uniqueStims(:,i)=[stimx(id); stimy(id)];
        end
        p.trial.(sn).uniqueStimsP=pds.deg2px(p.trial.(sn).uniqueStims,p.trial.display.viewdist, p.trial.display.w2px);
        p.trial.(sn).uniqueColors=diag(238+mod((1:length(p.trial.(sn).uniqueStimId))-1,7)+1)*ones(length(p.trial.(sn).uniqueStimId),3);
        
end %state switch
end%function

function overrideCurrentCalibrationMatrix(p,cm)

%this overrides any parallel arrow key presses
if p.trial.eyelink.use
    p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx) = cm;
end


end

function eye=getEye(p)

if p.trial.eyelink.use
    eyeIdx=p.trial.eyelink.eyeIdx;
    if p.trial.eyelink.useRawData
        eyeIdx=eyeIdx - 10; %the raw data is 10 fields prior to calibrated data
    end
    eye = p.trial.eyelink.samples(eyeIdx+[13 15],1:50:p.trial.eyelink.sampleNum);
else
    eye=p.trial.mouse.cursorSamples(:, 1:p.trial.mouse.samples(end));
end

end
 

function [g,r,o]=calibrationMatrixToGains(c,ctr)

% gains
g(1)=c(1,1); % xx gain
g(2)=c(2,2); % yy gain

% rotations
r(1)=c(2,1); % xy gain
r(2)=c(1,2); % yx gain

% calculate offset
ox=c(3,1);
oy=c(3,2);

cx = ( -g(2)*(ox - ctr(1)) + r(1)*(oy-ctr(2) ) ) / (g(1)*g(2) - r(1)*r(2));
cy = ( -g(1)*(oy - ctr(2)) + r(2)*(ox-ctr(1) ) ) / (g(1)*g(2) - r(1)*r(2));

o(1)=cx;
o(2)=cy;

end

function c=gainsToCalibrationMatrix(g,r,o,ctr)
% convert to calibration matrix
ox=-g(1)*o(1) - r(1)*o(2) + ctr(1);
oy=-g(2)*o(2) - r(2)*o(1) + ctr(2);

c(1,1)=g(1);
c(2,2)=g(2);
c(1,2)=r(2);
c(2,1)=r(1);
c=[c; ox oy];
end


function saveCalibrationAsRigPref(p,c)

    if p.trial.eyelink.use
        a=getpref('pldaps','eyelink');
        a.calibration_matrix = c;
        setpref('pldaps','eyelink',a); %set new
        disp('saved new calibration matrix.')
    end
    
    subj=p.trial.session.subject;
    setpref('marmoview_calibration', subj, c)
end

function c=getCalibrationPref(p)

    subj=p.trial.session.subject;
    if ~ispref('marmoview_calibration')
        c=[1 0; 0 1; 0 0]; % assume default calibration
        return
    end
    
    m=getpref('marmoview_calibration');
    if isfield(m, subj)
        c=m.(subj);
    else
        c=[1 0; 0 1; 0 0]; % assume default calibration
    end
    
end

function ctrlDown=isCtrlDown(p)
ctrlPressed=find(p.trial.keyboard.lastPressSamples(p.trial.keyboard.codes.Lctrl,:),1,'last');
if isempty(ctrlPressed)
    ctrlPressed=0;
else
    ctrlPressed=p.trial.keyboard.lastPressSamples(p.trial.keyboard.codes.Lctrl,ctrlPressed);
end

ctrlReleased=find(p.trial.keyboard.lastReleaseSamples(p.trial.keyboard.codes.Lctrl,:),1,'last');
if isempty(ctrlReleased)
    ctrlReleased=0;
else
    ctrlReleased=p.trial.keyboard.lastReleaseSamples(p.trial.keyboard.codes.Lctrl,ctrlReleased);
end
ctrlDown=ctrlPressed>ctrlReleased;
end