classdef trialstates < stimuli.objects.stateControl
    
    
    properties
        hFix@stimuli.objects.fixation
        hMot
        hTargs
        hCue
        hErr
        hFace
        eyeXY
        fixFlashCnt = 4
        timeTrialTimeout
        timeFixGracePeriod
        timeFixationObtained
        timeTargOnset
        timeMotionOnset
        timeMotionTurnedOn
        timeMotionTurnedOff
        timeMotionOffset
        timeCueOnset
        timeCueTurnedOn
        timeFixationOffset
        timeFixationTurnedOff
        timeFixDim
        timeStopFixationHold
        timeWaitForChoice
        timeChoiceGracePeriod
        timeChoiceHold
        timeFeedback
        timeITI
        timeChoiceMade
        windowMinEcc
        windowMaxEcc
        rewardCnt
        rewardToGive
        rewardFun
        iFrame=0
        choiceX=nan
        choiceY=nan
        choice=nan
        error=nan
        flagNextTrial=false
    end
    
    methods
        function o = trialstates(hFix,hMot,hTargs,hCue,hErr,hFace,varargin)
            o.hFix = hFix;
            o.hMot = hMot;
            o.hTargs = hTargs;
            o.hCue  = hCue;
            o.hErr  = hErr;
            o.hFace = hFace;
            
            ip = inputParser();
            ip.addOptional('timeTrialTimeout', 500);
            ip.addOptional('timeFixGracePeriod',    4);
            ip.addOptional('timeFixationObtained', nan);
            ip.addOptional('timeTargOnset',         4);
            ip.addOptional('timeMotionOnset',       4);
            ip.addOptional('timeMotionOffset',      4);
            ip.addOptional('timeCueOnset',          4);
            ip.addOptional('timeFixationOffset',    4);
            ip.addOptional('timeStopFixationHold',  4);
            ip.addOptional('timeWaitForChoice',     4);
            ip.addOptional('timeChoiceGracePeriod', 4);
            ip.addOptional('timeChoiceHold',        4);
            ip.addOptional('timeFeedback',          4);
            ip.addOptional('timeITI',               4);
            ip.addOptional('timeChoiceMade',        4);
            ip.addOptional('rewardCnt',             4);
            ip.addOptional('rewardFun',             4);
            ip.addOptional('windowMinEcc',             4);
            ip.addOptional('windowMaxEcc',             4);
            
            
            ip.parse(varargin{:});
            
            fields = fieldnames(ip.Results);
            for i = 1:numel(fields)
                o.(fields{i}) = ip.Results.(fields{i});
            end
        end
    end
    
end