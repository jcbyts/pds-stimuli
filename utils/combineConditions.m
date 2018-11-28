function c = combineConditions(conds)
% combine conditions
% c = combineConditions(conds)
%   conds is a cell aray of function handles that create condition structs
%   see hartleyFF_frozen_contrast_010.m

assert(iscell(conds), 'conds must be a cell array of function handles')

n = numel(conds);
cs = cell(n, 1);
for i = 1:n
    cs{i} = feval(conds{i});
end

c = cs{1};
for i = 2:n
    c = mergeStruct(c, cs{i});
end


    