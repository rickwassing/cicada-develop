function ACT = cic_editInformation(ACT, newInfo)
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Edit information');
% ---------------------------------------------------------
% Extract what fieldnames we have in newInfo
fnames = fieldnames(newInfo);
for fi = 1:length(fnames)
    % ---------------------------------------------------------
    % Extract all values from the new information structure and save them in ACT.info
    value = newInfo.(fnames{fi});
    ACT.info.(fnames{fi}) = value;
    % ---------------------------------------------------------
    % Write history
    if isstruct(value)
        % do nothing
        continue
    elseif isnumeric(value) && isempty(value)
        continue
    elseif ischar(value) || isstring(value)
        if isempty(deblank(value))
            continue
        end
        ACT.history = char(ACT.history, sprintf('ACT.info.%s = ''%s'';', fnames{fi}, value));
    elseif iscell(value)
        ACT.history = char(ACT.history, sprintf('ACT.info.%s = ''%s'';', fnames{fi}, value{:}));
    elseif islogical(value)
        ACT.history = char(ACT.history, sprintf('ACT.info.%s = %s;', fnames{fi}, ifelse(value, 'true', 'false')));
    elseif isnumeric(value) && mod(value, 1) == 0
        ACT.history = char(ACT.history, sprintf('ACT.info.%s = %i;', fnames{fi}, value));
    else
        ACT.history = char(ACT.history, sprintf('ACT.info.%s = %.4f;', fnames{fi}, value));
    end
end
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');

end % EOF
