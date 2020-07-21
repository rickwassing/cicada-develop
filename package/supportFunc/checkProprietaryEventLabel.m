function res = checkProprietaryEventLabel(label)
% Assume all is well
res = false;
% Modify label to make it non-case-matched and non-space-dependent
label = strrep(lower(label), ' ', '');
% Check if label is part of the no-go list
if ismember(label, {'start', 'button', 'reject', 'sleepwindow', 'sleepperiod', 'waso'})
    res = true;
end

end % EOF
