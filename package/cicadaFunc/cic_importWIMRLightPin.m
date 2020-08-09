function [ACT, err, warn, msg] = cic_importWIMRLightPin(ACT, fullpath)
% ---------------------------------------------------------
% Read the .CSV file as a table
% -----
% The difficulty here is that some variable names are integers, and are not
% recognized as variable names by the 'readtable()' function. We should
% extract the variable names from line 1, and then read lines 2 to Inf.
% -----
% Read variable names
fid = fopen(fullpath, 'r'); % open file for reading
varNames = strsplit(fgetl(fid), ','); % extract first line
varNames(cellfun(@(str) isempty(str), varNames)) = []; % remove any empty cells
fclose(fid); % close the file
% -----
% Check if the expected variables exist, otherwise throw error and return
% Set 'err' to false, i.e. assume all is well
err = false;
msg = '';
if all(~ismember({'Melanopic Lux', 'Photopic Lux', 'Erythropic Lux', 'Chloropic Lux', 'Cyanopic Lux', 'Rhodopic Lux'}, varNames))
    err = true;
    msg = 'The specified data file does not match a WIMR Light Pin data file because it did not contain all required fields. No data was imported.';
    return
end
% -----
% Read the table
opts = detectImportOptions(fullpath, 'DurationType', 'text', 'DatetimeType', 'text');
opts.DataLines = [2, Inf];
rawData = readtable(fullpath, opts);
rawData.Properties.VariableNames(1:length(varNames)) = matlab.lang.makeValidName(varNames);
% ---------------------------------------------------------
% Process the data
rawData.Date = datenum(rawData.Date, 'yy-mm-dd');
rawData.Time = mod(datenum(rawData.Time, 'HH:MM:SS'), 1);
% -----
% Initialize 'times' vector
times = (rawData.Date + rawData.Time);
% -----
% Crop data to min and max of the accelerometry data
idxRm = times < ACT.xmin | times > ACT.xmax;
rawData(idxRm, :) = [];
times(idxRm) = [];
% -----
% Get the sampling rate
srate = 1/mean(diff(times)); % samples per day, i.e. not in samples per second (Hz)
% -----
% Check if the data covers the entire timeseries of actiwatch data
warn = false;
if (times(1) - 1/srate) > ACT.xmin || (times(1) + 1/srate) < ACT.xmax
    warn = true;
    msg = sprintf('The WIMR Light Pin data does not cover the entire timeseries of the actigraphy data. \nActigraphy:\t%s - %s\nLight Pin:\t%s - %s', ...
        datestr(ACT.xmin, 'dd/mm/yyyy HH:MM'), ...
        datestr(ACT.xmax, 'dd/mm/yyyy HH:MM'), ...
        datestr(times(1), 'dd/mm/yyyy HH:MM'), ...
        datestr(times(end), 'dd/mm/yyyy HH:MM'));
end
% -----
% Store data in the metric structure
fnames = rawData.Properties.VariableNames(3:8);
for fi = 1:length(fnames)
    ACT.data.light.(fnames{fi}) = timeseries(rawData.(fnames{fi}), times, 'Name', fnames{fi});
    ACT.data.light.(fnames{fi}).DataInfo.Units = 'lux';
    ACT.data.light.(fnames{fi}).TimeInfo.Units = 'days';
    ACT.data.light.(fnames{fi}).TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
    ACT.data.light.(fnames{fi}).TimeInfo.StartDate = '00-Jan-0000 00:00:00';
    % Force the timeseries to have uniform interval
    ACT.data.light.(fnames{fi}) = setuniformtime(ACT.data.light.(fnames{fi}), 'StartTime', times(1), 'Interval', 1/srate);
end

% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Import Light Pin data');
ACT.history = char(ACT.history, sprintf('[ACT, err, warn, msg] = cic_importLightPin(ACT, ''%s'');', fullpath));
ACT.history = char(ACT.history, 'if err; error(msg); end');
ACT.history = char(ACT.history, 'if warn; warning(msg); end');

end % EOF
