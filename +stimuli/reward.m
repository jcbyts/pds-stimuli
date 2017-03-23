classdef reward < handle
    % REWARD class for delivering reward in psychophysical protocols
    % This is a HACK. It replicates info that is already stored in pldaps
    % so it can be called in a modular fashion instead of requiring all
    % classes that give reward to have access to pldaps in full
    
    properties
        datapixx
        newEraSyringePump
        sound
        
        defaultAmount
        timeReward
        iTrial
        iReward
        
        
    end
    
    methods
        function r = reward(p)
            
            % --
            r.datapixx.use          = p.trial.datapixx.use;
            r.datapixx.useForReward = p.trial.datapixx.useForReward;
            r.datapixx.rewardBit    = p.trial.event.REWARD;
            
            % --- control for sound
            r.sound.use             = p.trial.sound.use;
            r.sound.useForReward    = p.trial.sound.useForReward;
            if r.sound.use
                r.sound.reward      = p.trial.sound.reward;
            else
                r.sound.reward      = [];
            end
            
            % --- control for new era syringe pump
            r.newEraSyringePump = p.trial.newEraSyringePump;
            
            r.defaultAmount     = p.trial.behavior.reward.defaultAmount;
            r.iReward           = 1;
        end
        
        function give(r, amount)
            
            if nargin < 2
                amount = r.defaultAmount;
            end

            % --- Deliver reward with syringe pump
            if r.newEraSyringePump.use
                if nargin <2 %repeat last given Volume
                    IOPort('Write', r.newEraSyringePump.h, ['RUN' r.newEraSyringePump.commandSeparator],0);
                elseif amount>=0.001 && amount<=9999
                    IOPort('Write', r.newEraSyringePump.h, ['VOL ' sprintf('%*.*f', ceil(log10(amount)), min(3-ceil(log10(amount)),3),amount) r.newEraSyringePump.commandSeparator 'RUN' r.newEraSyringePump.commandSeparator],0);
                end
            end
            
            % --- record event with datapixx
            if r.datapixx.use
                if  r.datapixx.useForReward
                    pds.datapixx.analogOut(amount);
                end
                %%flag
                pds.datapixx.flipBit(r.datapixx.rewardBit,r.iTrial);
            end
    
            % --- play sound
            if r.sound.use && r.sound.useForReward
                PsychPortAudio('Start', r.sound.reward);
            end
            
            % --- store data
            r.timeReward(r.iReward,:) = [GetSecs amount];
            r.iReward = r.iReward + 1;
            
        end % give
        
    end % Methods
    
end % classdef  