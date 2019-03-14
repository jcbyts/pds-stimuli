function resetStimulusLogs(s)

fields = fieldnames(s);

for i = 1:numel(fields)
    if numel(s) > 1 % if struct array, this leads nowhere good
        continue
    elseif isa(s.(fields{i}), 'stimuli.objects.stimulus')
        for j = 1:numel(s.(fields{i}))
            s.(fields{i})(j).initLog();
        end
    elseif isstruct(s.(fields{i}))
        resetStimulusLogs(s.(fields{i}))
    end
end