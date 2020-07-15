function [parsedDate, err, msg] = parseSleepDiaryDate(rawValues, formatIn, formatOut)

% Set 'err' to false, i.e. assume all is well
err = false;
msg = '';

try
    % Initialize parsedDate as empty cell array
    parsedDate = cell(length(rawValues), 1);
    % Remove the rows with missing values
    missingRows = ismissing(rawValues);
    rawValues(missingRows) = [];
    % Convert the raw dates from their specified format-in to format-out
    tmp = cellstr(datestr(datenum(rawValues, formatIn), formatOut));
    % Insert the parsed dates into the cell array 'parserDate'
    cnt = 0;
    for vi = 1:length(parsedDate)
        if missingRows(vi)
            parsedDate{vi} = '';
        else
            cnt = cnt+1;
            parsedDate{vi} = tmp{cnt};
        end
    end
catch
    % The conversion resulted in an error
    parsedDate = nan(size(rawValues));
    err = true;
    msg = 'Error in parseSleepDiaryDate (line 14). Date formatting failed';
end

end % EOF
