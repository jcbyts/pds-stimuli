function varargout = rewardUpdateSwitchRule(choices, rate1, rate2, Param)
% varargout = rewardUpdateSwitchRule(choices, rate1, rate2, Param)

% simplest way to start is to switch randomly with some improbable rate
assert(Param > 0 & Param < 1, 'Param governs switch rate, must be between 0 and 1');


%********* do random switching, but if she is going to the same place
%********* over and over again, then try to swap it
z = find( ~isnan(choices));
chons = choices(z);
%**********
M = size(chons,2);
H = max(1,(M-10));
LeftC = size(find(chons(H:M) == 2),2);
RightC = size(find(chons(H:M) == 1),2);
%**********
[LeftC,RightC]
%***********
if (LeftC >= 8) | (RightC >= 8)
    
   if (LeftC >= 5)  % if going all left, change right to max reward
       varargout{1} = max(rate1,rate2);  %right reward
       varargout{2} = min(rate1,rate2);  %left reward
   else
       varargout{1} = min(rate1,rate2);
       varargout{2} = max(rate1,rate2);
   end
    
else   % just swap at random otherwise
    
  if rand < Param % switch reward
    
     varargout{1} = rate2;
     varargout{2} = rate1;
    
  else            % stay same state
    varargout{1} = rate1;
    varargout{2} = rate2;
  end
  %*************
  [varargout{1},varargout{2}]
  %************
end
    
