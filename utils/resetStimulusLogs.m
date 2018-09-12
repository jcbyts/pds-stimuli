function resetStimulusLogs(s)

fields = fieldnames(s);

for i = 1:numel(fields)
    if isa(s.(fields{i}), 'stimuli.objects.stimulus')
        s.(fields{i}).initLog();
    elseif isstruct(s.(fields{i}))
        resetStimulusLogs(s.(fields{i}))
    end
end