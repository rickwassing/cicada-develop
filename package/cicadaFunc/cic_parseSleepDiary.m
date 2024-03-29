function [ACT, err, msg] = cic_parseSleepDiary(ACT, rawTable, importSettings)
% ---------------------------------------------------------
% Initialize DIARY as an empty table
ACT.analysis.sleepDiary = table();
% Set 'err' to false, i.e. assume all is well
err = false;
msg = '';
% ---------------------------------------------------------
% Extract all variable names from the raw data table
items = rawTable.Properties.VariableNames;
% ---------------------------------------------------------
% Try to parse the date, we assume a datestring with day, month and year
if isempty(importSettings.idx.date)
    ACT.analysis.sleepDiary.date = nan(size(rawTable, 1), 1);
    err = true;
    msg = 'The ''date'' variable is required, but its column index in the import settings is empty. Please select the appropriate variable.';
else
    [ACT.analysis.sleepDiary.date, parseErr] = parseSleepDiaryDate(rawTable.(items{importSettings.idx.date}), importSettings.format.date, 'dd/mm/yyyy');
    if parseErr
        err = true;
        msg = sprintf('The ''date'' variable is required, but Cicada could not parse ''date'' as ''%s''', importSettings.format.date);
    end
end
% ---------------------------------------------------------
% Try to parse the lights out date-time, we assume a datestring with at least the hours and minutes
if isempty(importSettings.idx.lightsOut)
    ACT.analysis.sleepDiary.lightsOut = nan(size(rawTable, 1), 1);
    if ~err
        err = true;
        msg = 'The ''lightsOut'' variable is required, but its column index in the import settings is empty. Please select the appropriate variable.';
    end
else
    [ACT.analysis.sleepDiary.lightsOut, parseErr] = parseSleepDiaryDateTime(ACT.analysis.sleepDiary.date, rawTable.(items{importSettings.idx.lightsOut}), importSettings.format.lightsOut);
    if parseErr && ~err
        err = true;
        msg = sprintf('The ''lightsOut'' variable is required, but Cicada could not parse ''lightsOut'' as ''%s''', importSettings.format.lightsOut);
    end
end
% ---------------------------------------------------------
% Try to parse the sleep onset latency, we assume an integer in minutes
try
    if strcmpi(importSettings.format.sleepLatency, 'minutes')
        ACT.analysis.sleepDiary.sleepLatency = round(double(rawTable.(items{importSettings.idx.sleepLatency})));
    elseif strcmpi(importSettings.format.sleepLatency, 'HH:MM')
        for i = 1:length(rawTable.(items{importSettings.idx.sleepLatency}))
            try
                ACT.analysis.sleepDiary.sleepLatency(i, 1) = round(mod(datenum(rawTable.(items{importSettings.idx.sleepLatency})(i), 'HH:MM'), 1) * 24*60);
            catch
                ACT.analysis.sleepDiary.sleepLatency(i, 1) = NaN;
            end
        end
    else
        ACT.analysis.sleepDiary.sleepLatency = nan(size(rawTable, 1), 1);
    end
catch
    ACT.analysis.sleepDiary.sleepLatency = nan(size(rawTable, 1), 1);
    % Sleep Latency is not required, so do not trow an error
end
% ---------------------------------------------------------
% Try to parse the number of nighttime awakenings, we assume an integer
try
    ACT.analysis.sleepDiary.awakenings = round(double(rawTable.(items{importSettings.idx.awakenings})));
catch
    ACT.analysis.sleepDiary.awakenings = nan(size(rawTable, 1), 1);
    % Number of awakenings is not required, so do not trow an error
end
% ---------------------------------------------------------
% Try to parse wake after sleep onset, we assume an integer in minutes
try
    if strcmpi(importSettings.format.waso, 'minutes')
        ACT.analysis.sleepDiary.waso = round(double(rawTable.(items{importSettings.idx.waso})));
    elseif strcmpi(importSettings.format.waso, 'HH:MM')
        for i = 1:length(rawTable.(items{importSettings.idx.waso}))
            try
                ACT.analysis.sleepDiary.waso(i, 1) = round(mod(datenum(rawTable.(items{importSettings.idx.waso})(i), 'HH:MM'), 1) * 24*60);
            catch
                ACT.analysis.sleepDiary.waso(i, 1) = NaN;
            end
        end
    else
        ACT.analysis.sleepDiary.waso = nan(size(rawTable, 1), 1);
    end
catch
    ACT.analysis.sleepDiary.waso = nan(size(rawTable, 1), 1);
    % WASO is not required, so do not trow an error
end
% ---------------------------------------------------------
% Try to parse the final awakening date-time, we assume a datestring with at least the hours and minutes
if isempty(importSettings.idx.finAwake)
    ACT.analysis.sleepDiary.finAwake = nan(size(rawTable, 1), 1);
    % Final awakening is not required, so do not trow an error
else
    ACT.analysis.sleepDiary.finAwake = parseSleepDiaryDateTime(ACT.analysis.sleepDiary.date, rawTable.(items{importSettings.idx.finAwake}), importSettings.format.finAwake);
    % Final awakening is not required, so do not trow an error
end
% ---------------------------------------------------------
% Try to parse the lights on date-time, we assume a datestring with at least the hours and minutes
if isempty(importSettings.idx.lightsOn)
    ACT.analysis.sleepDiary.lightsOn = nan(size(rawTable, 1), 1);
    if ~err
        err = true;
        msg = 'The ''lightsOn'' variable is required, but its column index in the import settings is empty. Please select the appropriate variable.';
    end
else
    [ACT.analysis.sleepDiary.lightsOn, parseErr] = parseSleepDiaryDateTime(ACT.analysis.sleepDiary.date, rawTable.(items{importSettings.idx.lightsOn}), importSettings.format.lightsOn);
    if parseErr && ~err
        err = true;
        msg = sprintf('The ''lightsOn'' variable is required, but Cicada could not parse ''lightsOn'' as ''%s''', importSettings.format.lightsOn);
    end
end

% ---------------------------------------------------------
% Remove rows that have missing required data, i.e. date, lights out and lights on
feedback.orig = 1:size(ACT.analysis.sleepDiary, 1);
feedback.removed = [];
[row, col] = find(ismissing(ACT.analysis.sleepDiary));
requiredMissing = unique(row(col == 1 | col == 2 | col == 7));
ACT.analysis.sleepDiary(requiredMissing, :) = [];
feedback.removed = [feedback.removed, feedback.orig(requiredMissing)];
% ---------------------------------------------------------
% Remove rows that have negative sleep window duration or overlapping sleep windows
if ~isempty(ACT.analysis.sleepDiary.lightsOut)
    sleepWindowsOnset = datenum(ACT.analysis.sleepDiary.lightsOut, 'dd/mm/yyyy HH:MM');
    sleepWindowsOffset = datenum(ACT.analysis.sleepDiary.lightsOn, 'dd/mm/yyyy HH:MM');
    errorIdx = [];
    for i = 1:size(ACT.analysis.sleepDiary, 1)
        thisOnset = datenum(ACT.analysis.sleepDiary.lightsOut{i}, 'dd/mm/yyyy HH:MM');
        thisOffset = datenum(ACT.analysis.sleepDiary.lightsOn{i}, 'dd/mm/yyyy HH:MM');
        sleepWindowDuration = thisOffset - thisOnset;
        if sleepWindowDuration < 0
            errorIdx = [errorIdx, i];
            %
            % #1 overlaps with start
            % |-----------|
            %       |-----------|
        elseif any(...
                thisOnset < sleepWindowsOnset & ...
                thisOnset < sleepWindowsOffset & ...
                thisOffset > sleepWindowsOnset & ...
                thisOffset < sleepWindowsOffset)
            errorIdx = [errorIdx, i];
            %
            % #2 overlaps in the middle
            %         |-------|
            %       |-----------|
        elseif any(...
                thisOnset > sleepWindowsOnset & ...
                thisOnset < sleepWindowsOffset & ...
                thisOffset > sleepWindowsOnset & ...
                thisOffset < sleepWindowsOffset)
            errorIdx = [errorIdx, i];
            %
            % #3 overlaps with end
            %             |-----------|
            %       |-----------|
        elseif any(...
                thisOnset > sleepWindowsOnset & ...
                thisOnset < sleepWindowsOffset & ...
                thisOffset > sleepWindowsOnset & ...
                thisOffset > sleepWindowsOffset)
            errorIdx = [errorIdx, i];
            %
            % #3 overlaps across
            %     |---------------|
            %       |-----------|
        elseif any(...
                thisOnset < sleepWindowsOnset & ...
                thisOnset < sleepWindowsOffset & ...
                thisOffset > sleepWindowsOnset & ...
                thisOffset > sleepWindowsOffset)
            errorIdx = [errorIdx, i];
        end
    end
    if ~isempty(errorIdx)
        feedback.removed = [feedback.removed, feedback.orig(errorIdx)];
        ACT.analysis.sleepDiary(errorIdx, :) = [];
    end
    if ~isempty(feedback.removed) && ~err
        err = true;
        msg = sprintf('%i rows removed because of missing required data, negative sleep window duration, or overlap with another sleep window.\nRows removed: %s', length(feedback.removed), strjoin(string(feedback.removed), ', '));
    end
end
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Parse the raw sleep diary data according to its import settings');
ACT.history = char(ACT.history, '[ACT, err, msg] = cic_parseSleepDiary(ACT, rawSleepDiary, importSettings);');
ACT.history = char(ACT.history, 'if err; error(msg); end');

end % EOF
