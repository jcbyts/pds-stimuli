function varargout = rewardUpdateSwitchRule(choices, rate1, rate2, stimVis, Param, TSwap)
% varargout = rewardUpdateSwitchRule(choices, rate1, rate2, stimVis, Param, TSwap)

% simplest way to start is to switch randomly with some improbable rate
assert(Param > 0 & Param < 1, 'Param governs switch rate, must be between 0 and 1');


%********* do random switching, but if she is going to the same place
%********* over and over again, then try to swap it
%z = find( ~isnan(choices));
%chons = choices(z);
%**********
TF = TSwap; % she needs to sample one side TF times before it swaps

size(choices)
disp('check this');

ZN = size(choices,2);  % most recent choice
if (~isnan(choices(ZN)))
  if (choices(ZN) == 2) % choose left last trial
    stimVis(4) = stimVis(4) + 1;  %past counts of left
  end
  if (choices(ZN) == 1) % choose right last trial
    stimVis(5) = stimVis(5) + 1; % past counts of right
  end
end
LeftC = stimVis(4);
RightC = stimVis(5);
%**********
disp(sprintf('Counting Left,Right sampling (%d and %d)',LeftC,RightC));
varargout{1} = rate1;
varargout{2} = rate2;
varargout{3} = stimVis;
%***********

if (stimVis(3) == 0)   % for two target mode presentation

 if (LeftC >= TF) || (RightC >= TF)
      
   disp('*******************************');  
     
   disp('Doing the swap');
   [varargout{1},varargout{2}]
   stimVis
   if (LeftC >= TF)  % if going all left, change right to max reward
       varargout{1} = max(rate1,rate2);  %right reward
       varargout{2} = min(rate1,rate2);  %left reward
       stimVis = [1 0.05 stimVis(3) 0 0];  % show right only
   else
       varargout{1} = min(rate1,rate2);
       varargout{2} = max(rate1,rate2);
       stimVis = [0.05 1 stimVis(3) 0 0];
   end
   
   disp('Done with the swap');
   [varargout{1},varargout{2}]
   stimVis
   
   disp('*******************************');
   
      
 else   % just swap at random otherwise
   
   % if (sum(stimVis(1:2)) == 2)) then with some prob move from singleton to
   % double stimulus presenation (random duration intro)
   if (sum(stimVis(1:2)) < 2)
       if (stimVis(1) < 1)
          myVis = 1;    
       else
          myVis = 2; 
       end
       %******* transition immediately to full contrast
       if (1)
          stimVis = [1 1 stimVis(3:5)];
       else   % or fade it in gradually
          stimVis(myVis) = stimVis(myVis) * 2;  % increase contrast
          if (stimVis(myVis) > 1)
             stimVis = [1 1 stimVis(3:5)];   % at this point is 
                                             % [1 1 0 leftcount rightcount], dual trials
          end
       end
   end
   %********************
    
 end

else    % this is for single target presentation mode

   if rand < Param % switch reward
          
       varargout{1} = rate2;
       varargout{2} = rate1;    
          
   end
   
   if (varargout{1} > varargout{2})
      stimVis = [1 0 stimVis(3:5)];
   else
      stimVis = [0 1 stimVis(3:5)];
   end

end


%*************
% [varargout{1},varargout{2}]
% stimVis
%************
  
varargout{3} = stimVis;

    
