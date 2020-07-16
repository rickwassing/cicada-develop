function ACT = cic_importLightPin(ACT, fullpath)
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
% Crop data to min and max of the accelerometry data
idxRm = (rawData.Date + rawData.Time) < ACT.xmin | (rawData.Date + rawData.Time) > ACT.xmax;
rawData(idxRm, :) = [];
% -----
% Initialize 'times' vector
times = (ACT.xmin:mean(diff(rawData.Date + rawData.Time)):ACT.xmax)';
startIdx = find((rawData.Date + rawData.Time) >= times(1), 1, 'first')
data = nan(size(times));
data(times >= (rawData.Date + rawData.Time) && times <= (rawData.Date + rawData.Time)) = rawData.(fnames{fi})
% -----
% Store in the metric structure
fnames = rawData.Properties.VariableNames(3:26);
for fi = 1:length(fnames)
    ACT.metric.light.(fnames{fi}) = timeseries(rawData.(fnames{fi}), rawData.Date + rawData.Time, 'Name', fnames{fi});
    ACT.metric.light.(fnames{fi}).TimeInfo.Units = 'days';
end

% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Import Light Pin data');
ACT.history = char(ACT.history, sprintf('ACT = cic_importLightPin(ACT, ''%s'');', fullpath));

end % EOF
