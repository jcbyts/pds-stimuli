function c = buildConditions(conds, N)

n = numel(conds);
assert(n==numel(N), 'number of conditions and N must match')

finish = sum(N);

condIdx = [];
for i = 1:n
    condIdx = [condIdx; ones(N(i), 1)*i];
end
    
c = cell(finish, 1);

for iTrial = 1:finish
    c{iTrial} = conds{condIdx(iTrial)};
end
