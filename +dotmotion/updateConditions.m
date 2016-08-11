function updateConditions(p, sn)

%%conditions
%create some conditions. not pretty yet
% p.trial.(sn)
% n=p.trial.(sn).nDirections;
% nRepeats=20;
% A.direction = mod(round((rand()*360)/(360/n))*(360/n),360);

% p.trial.pldaps.iTrial

c.Nr=1; %one condition;
p.conditions=repmat({c},1,200);
%  cc.clockwise = [false, true];%0 1 
%     %have boolean switch whether to keep the motion vector length constant
%  cc.randomizeStart=[1];%0 1 
%  
%  cc.frequency=[1 1.25 0.5]; %Hz
%  cc.dotSpeed=[15]; %deg/second
    
%  fn=fieldnames(cc);
%  numConds=1;
%  for parameter=1:length(fn)
%      numConds=numConds*length(cc.(fn{parameter}));
%  end
 
%  c=cell(1,numConds);
%  numCondsTillNow=1;
%  for parameter=1:length(fn)
%      numParmValues=length(cc.(fn{parameter}));
%      
%      for condition=1:numConds
%          thisParmValue=floor(mod((condition-1)/numCondsTillNow,numParmValues)+1);
%          if(isnumeric(cc.(fn{parameter})) || islogical(cc.(fn{parameter})))
%              c{condition}.(fn{parameter})=cc.(fn{parameter})(thisParmValue);
%          else
%              fn2=fieldnames(cc.(fn{parameter}){thisParmValue});
%              for ParmValueField=1:length(fn2)
%                 c{condition}.(fn2{ParmValueField})=cc.(fn{parameter}){thisParmValue}.(fn2{ParmValueField});
%              end            
%          end
%          
%      end
%      
%      numCondsTillNow=numCondsTillNow*numParmValues;
%  end
%  
% 
%   
%  for(condition=1:numConds)
%      ctmp.stimulus.motion1=c{condition};
%      ctmp.nr = condition;
%      c{condition}=ctmp;
%  end
%  
%  c=repmat(c,1,200);
%   
% p.conditions=Shuffle(c); %rand , can't specifiy the rng here, but we set the default so it's ok.
