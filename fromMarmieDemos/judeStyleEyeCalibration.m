function p=judeStyleEyeCalibration(p,state,sn)

    switch state        

        case p.trial.pldaps.trialStates.framePrepareDrawing
           
            p.trial.(sn).eyeposMovAv = 10;

            if p.trial.eyelink.use
                eyeIdx=p.trial.eyelink.eyeIdx;
                if p.trial.eyelink.useRawData
                    eyeIdx=eyeIdx - 10; %the raw data is 10 fields prior to calibrated data
                end
            else
                eyeIdx=1;
            end
            
            % check keyboard presses
            if any(p.trial.keyboard.firstPressQ)
                
                % is Ctrl held
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
                
                % calibration matrix
                b=p.trial.(sn).b;
                changedMatrix=false;
                gnstep=.01;
                offstep=50;
                
                % center
                if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.cKey)
                    if p.trial.eyelink.use
                     eye = mean(p.trial.eyelink.samples(eyeIdx+[13 15],p.trial.eyelink.sampleNum),2);
                    else
                     eye = p.trial.mouse.cursorsamples;
                    end
                     b(3,1:2)=-eye'+p.trial.display.ctr(1:2);
                     b(1,1)=-.01;
                     b(2,2)=-.01;
                     b(1,2)=0;
                     b(2,1)=0;
                end
                
                % decrease x
                if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Larrow)
                    if  ctrlDown % gain
                      b(1,1) = b(1,1)-gnstep;
                    else % offset
                      b(3,1) = b(3,1)-offstep;
                    end
                    changedMatrix=true;
                end

                % increase x
                if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Rarrow)
                    if  ctrlDown % gain
                      b(1,1) = b(1,1)+gnstep;
                    else % offset
                      b(3,1) = b(3,1)+offstep;
                    end
                    changedMatrix=true;
                end

                % decrease y
                if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Darrow)
                    if  ctrlDown % gain
                      b(2,2) = b(2,2)-gnstep;
                    else % offset
                      b(3,2) = b(3,2)-offstep;
                    end
                    changedMatrix=true;
                end

                % increase y
                if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Uarrow)
                    if  ctrlDown % gain
                      b(2,2) = b(2,2)+gnstep;
                    else % offset
                      b(3,2) = b(3,2)+offstep;
                    end
                    changedMatrix=true;
                end
                p.trial.(sn).b = b;

                %copy current estimate to manual
                if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.xKey)
                    %copy current estimate to manual
                    if  ~ctrlDown
                        %this overrides any parallel arrow key presses
                        cm=p.trial.(sn).b;
                        cm(3,:)=p.trial.display.ctr(1:2)-cm(3,:).*[cm(1,1) cm(2,2)];
                        p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx) = cm';
                    else %save as new rig pref
                        a=getpref('pldaps','eyelink');
                        a.calibration_matrix = p.trial.eyelink.calibration_matrix;
                        setpref('pldaps','eyelink',a); %set new
                        display('saved new calibration matrix.')
                    end
                    changedMatrix=true;
                end
                
                if changedMatrix
                    p.trial.(sn).clickedEyePos=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)*[p.trial.(sn).rawEye;ones(1,size(p.trial.(sn).rawEye,2))];
                end
                
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
            
            if p.trial.(sn).drawStims
                %draw all possible stimulus locations
                Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.(sn).uniqueStimsP, ...
                             6, p.trial.(sn).uniqueColors', p.trial.display.ctr(1:2),0);

                %draw markers
                if ~isempty(p.trial.(sn).clickedEyePos)
                    Screen('Drawdots',  p.trial.display.overlayptr, p.trial.(sn).clickedEyePos, ...
                             4, p.trial.(sn).uniqueColors(p.trial.(sn).clickedEyeStim,:)', [0 0],0);
                end
            end
                %draw the eyepos from current live calibration
                eyeIdx=p.trial.eyelink.eyeIdx;
                if p.trial.eyelink.useRawData
                    eyeIdx=eyeIdx - 10; %the raw data is 10 fields prior to calibrated data
                end
                eye = p.trial.eyelink.samples(eyeIdx+[13 15],1:50:p.trial.eyelink.sampleNum);
                
                ex=eye(1,:)-p.trial.(sn).b(3,1);
                ey=eye(2,:)-p.trial.(sn).b(3,2);

                eye=[ex*p.trial.(sn).b(1,1)+p.trial.display.ctr(1); ey*p.trial.(sn).b(2,2)+p.trial.display.ctr(2)];
                
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
                
                b=1; %
%                 b=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)';
%                 b(3,:)=-p.trial.display.ctr(1:2)+b(3,:).*[b(1,1) b(2,2)];
                p.trial.(sn).b = b;
            end
            display(p.trial.pldaps.iTrial)
            for kTarg=1:numel(p.trial.stimulus.target)
               p.trial.stimulus.target(kTarg).saveout=nan(4,20); 
            end
            p.trial.stimulus.arrayIndex=1;

        case p.trial.pldaps.trialStates.trialCleanUpandSave
            for kTarg=1:numel(p.trial.stimulus.target)
                p.trial.stimulus.target(kTarg).saveout(:,isnan(p.trial.stimulus.target(kTarg).saveout(1,:)))=[];
            end
%           
%             %fixation refinedment:
%             %add a marker at the median fixation using the window sued for
%             %reward in that trial.
%             if p.trial.(sn).refineCalibratrionFromWindow && p.trial.pldaps.goodtrial
% %                iTrial=4;p.trial.stimulus.target.initialXY=PDS.conditions{iTrial}.stimulus.target.initialXY;p.trial.eyelink.samples(eyeIdx+[13 15],:)=PDS.data{iTrial}.eyelink.samples([6 7],:);
%                winsize=p.trial.stimulus.target.motionstates.fixationWindow(1);
%                winsize=pds.deg2px([winsize;0], p.trial.display.viewdist, p.trial.display.w2px);
%                winsize=winsize(1);
%                
%                loc=pds.deg2px(p.trial.stimulus.target.initialXY, p.trial.display.viewdist, p.trial.display.w2px)+ p.trial.display.ctr(1:2)';
%                
%                eyeIdx=p.trial.eyelink.eyeIdx;
%                if p.trial.eyelink.useRawData
%                    eyeIdx=eyeIdx - 10; %the raw data is 10 fields prior to calibrated data
%                end
% 
%                eye = p.trial.eyelink.samples(eyeIdx+[13 15],:); 
%               
%                eyeXY=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)*[eye;ones(1,size(eye,2))];
%                inwindow=sqrt(sum( (eyeXY - diag(loc)*ones(size(eyeXY))).^2 ))<winsize;
%                eyeMedian=median(eyeXY(:,inwindow),2);
%                inwindow=sqrt(sum( (eyeXY - diag(eyeMedian)*ones(size(eyeXY))).^2 ))<winsize;
%                eyeMedian=median(eye(:,inwindow),2); 
%                
%                p.trial.(sn).rawEye(:,end+1)=eyeMedian;
%                p.trial.(sn).stimPos(:,end+1)=loc;
%                p.trial.(sn).clickedEyePos(:,end+1)=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)*[eyeMedian;1];  
%                id=find(sum(p.trial.stimulus.target(1).initialXY.*[1; 1000]) == p.trial.(sn).uniqueStimId, 1);
%                p.trial.(sn).clickedEyeStim(:,end+1)=id;
%             end
% 
%             %marker regression
%             eye=p.trial.(sn).rawEye;
%             stim=p.trial.(sn).stimPos;
%             
%             eye(eye==-32768) = NaN;
%             eye(eye==100000000) = NaN;
%             
%             rem=any(isnan(eye));
%             eye(:,rem)=[];
%             stim(:,rem)=[];
% %             stim=stim+diag(p.trial.display.ctr(1:2))*ones(size(stim));
%             p.trial.(sn).b=[eye; ones(1,size(eye,2))]'\stim';
%             display(p.trial.(sn).b);
%% experiment
        case p.trial.pldaps.trialStates.experimentPreOpenScreen
%%            
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

        case p.trial.pldaps.trialStates.experimentPostOpenScreen
 %%
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