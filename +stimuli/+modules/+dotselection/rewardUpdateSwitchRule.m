function varargout = rewardUpdateSwitchRule(choices, rate1, rate2, stimVis, Param)
% varargout = rewardUpdateSwitchRule(choices, rate1, rate2, stimVis, Param)

% simplest way to start is to switch randomly with some improbable rate
assert(Param > 0 & Param < 1, 'Param governs switch rate, must be between 0 and 1');


%********* do random switching, but if she is going to the same place
%********* over and over again, then try to swap it
z = find( ~isnan(choices));
chons = choices(z);
%**********
TM = 20;
TF = 16;  % if in a 20 trial history, you went to one more than 20
M = size(chons,2);
H = max(1,(M-TM));
LeftC = size(find(chons(H:M) == 2),2);
RightC = size(find(chons(H:M) == 1),2);
%**********
[LeftC,RightC]
varargout{1} = rate1;
varargout{2} = rate2;
varargout{3} = stimVis;
%***********

if (stimVis(3) == 0)   % for two target mode presentation

 if (LeftC >= TF) || (RightC >= TF)
      
   if (LeftC >= TF)  % if going all left, change right to max reward
       varargout{1} = max(rate1,rate2);  %right reward
       varargout{2} = min(rate1,rate2);  %left reward
       stimVis = [1 0 stimVis(3)];  % show right only
   else
       varargout{1} = min(rate1,rate2);
       varargout{2} = max(rate1,rate2);
       stimVis = [0 1 stimVis(3)];
   end
      
 else   % just swap at random otherwise
    
  if rand < Param % switch reward
       
     if (sum(stimVis) == 2)   % if singleton, first start trans just stay same side
                              % but make both targets become visible
       varargout{1} = rate2;
       varargout{2} = rate1;
       
     else
         
       stimVis = [1 1 stimVis(3)];
     
     end
        
  end
 end

else    % this is for single target presentation mode

   if rand < Param % switch reward
          
       varargout{1} = rate2;
       varargout{2} = rate1;    
          
   end
   
   if (varargout{1} > varargout{2})
      stimVis = [1 0 stimVis(3)];
   else
      stimVis = [0 1 stimVis(3)];
   end

end


%*************
% [varargout{1},varargout{2}]
% stimVis
%************
  
varargout{3} = stimVis;

    
