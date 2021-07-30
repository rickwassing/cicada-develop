function [dateTime, err, msg] = parseSleepDiaryDurationTime(thisTime, format)

% Set 'err' to false, i.e. assume all is well
err = false;
msg = '';

% -----
% First check whether 'thisTime' is of type numeric, if so, convert directly
if isnumeric(thisTime)
        % Parse 'thisTime' 
        try
            dateTime = cellstr(datestr(thisTime, 'HH:MM'));
        catch
            % The conversion resulted in an error
            dateTime = nan(size(thisTime));
            err = true;
            msg = 'Error in parseSleepDiaryDateTime (lines 41). Date-time formatting failed';
        end
else
end






if isnumeric(thisTime)
    % If 'thisTime' only encodes time, and not the date, get the date from 'thisDate'
    if all(thisTime(~isnan(thisTime)) < 1)
        try
            % Initialize 'dateTime' as an empty cell array
            dateTime = cell(length(thisTime), 1);
            % For each date-time in 'thisTime' ...
            for di = 1:length(thisTime)
                % Chech if values are missing, if not:
                if ~ismissing(thisTime(di)) && ~ismissing(thisDate(di))
                    % parse the date
                    thisDate{di} = datenum(thisDate{di}, 'dd/mm/yyyy');
                    % Add the date and time together (minus one day if 'thisTime' is after 15:00)
                    dateTime{di} = thisDate{di} + ...    % The date
                        (thisTime(di) < (15/24))-1 + ... % Subtract a day if after 15:00
                        thisTime(di);                    % And add the time
                    % Convert the date-time to 'dd/mm/yyyy HH:MM'
                    dateTime{di} = datestr(dateTime{di}, 'dd/mm/yyyy HH:MM');
                else
                    % Value is missing, so return empty string
                    dateTime{di} = '';
                end
            end
        catch
            % The conversion resulted in an error
            dateTime = nan(size(thisTime));
            err = true;
            msg = 'Error in parseSleepDiaryDateTime (lines 20 or 26). Date-time formatting failed';
        end
    else
        % Parse 'thisTime' 
        try
            dateTime = cellstr(datestr(thisTime, 'dd/mm/yyyy HH:MM'));
        catch
            % The conversion resulted in an error
            dateTime = nan(size(thisTime));
            err = true;
            msg = 'Error in parseSleepDiaryDateTime (lines 41). Date-time formatting failed';
        end
    end
    % -----
    % Else, 'thisTime' is a string and if it includes a day, month, and a year, then we can parse
    % the date-time without using the 'thisDate' variable to indicate the date.
elseif ...
        strRegexpCheck(format, 'd') && ...
        strRegexpCheck(format, 'm') && ...
        strRegexpCheck(format, 'y')
    try
        % Initialize 'dateTime' as an empty cell array
        dateTime = cell(length(thisTime), 1);
        % For each date-time in 'thisTime' ...
        for di = 1:length(thisTime)
            % Chech if its value is missing, if not:
            if ~ismissing(thisTime{di})
                % Convert the date-time to 'dd/mm/yyyy HH:MM'
                dateTime{di} = datestr(datenum(thisTime{di}, format), 'dd/mm/yyyy HH:MM');
            else
                % Value is missing, so return empty string
                dateTime{di} = '';
            end
        end
    catch
        % The conversion resulted in an error
        dateTime = nan(size(thisTime));
        err = true;
        msg = 'Error in parseSleepDiaryDateTime (line 64). Date-time formatting failed';
    end
    
    % -----
    % Otherwise, if the string 'thisTime' does not include a day, month and year,
    % then we have to parse the date-number with 'thisDate' to indicate the date.
    % In this case, we make the following assumption: 'thisDate' indicates the
    % date the sleep diary was completed, and 'thisTime' refers to the time of
    % a particular sleep event, e.g. lights off, final awakening, etc. If 'thisTime'
    % is after 15:00, i.e. late afternoon until midnight, this time refers to a
    % sleep event that happened yesterday, i.e. 'thisDate' minus 1 day.
    % Otherwise, if 'thisTime is before 15:00, i.e. between midnight and 15:00, this time
    % refers to a sleep event that happend the same day as the diary was completed.
else
    try
        % Initialize 'dateTime' as an empty cell array
        dateTime = cell(length(thisTime), 1);
        % For each date-time in 'thisTime' ...
        for di = 1:length(thisTime)
            % Chech if values are missing, if not:
            if ~ismissing(thisTime(di)) && ~ismissing(thisDate(di))
                % parse the time
                thisTime{di} = mod(datenum(thisTime{di}, format), 1);
                % parse the date
                thisDate{di} = datenum(thisDate{di}, 'dd/mm/yyyy');
                % Add the date and time together (minus one day if 'thisTime' is after 15:00)
                dateTime{di} = thisDate{di} + ...    % The date
                    (thisTime{di} < (15/24))-1 + ... % Subtract a day if after 15:00
                    thisTime{di};                    % And add the time
                % Convert the date-time to 'dd/mm/yyyy HH:MM'
                dateTime{di} = datestr(dateTime{di}, 'dd/mm/yyyy HH:MM');
            else
                % Value is missing, so return empty string
                dateTime{di} = '';
            end
        end
    catch
        % The conversion resulted in an error
        dateTime = nan(size(thisTime));
        err = true;
        msg = 'Error in parseSleepDiaryDateTime (lines 98 or 104). Date-time formatting failed';
    end
end