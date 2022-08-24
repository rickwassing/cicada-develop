function [value, timeOnset, metricPerWin] = getAvMetric(ACT, metric, times, varargin)

% Calculate the mean of a metric during a window of least or maximum values
% of that metric between a start and end date. 
% (1) This algorhythm selects data between a start and end date and can 
% include week days only, weekend only, or all days. 
% (2) For each epoch of the day, it calculates the mean of the metric 
% across all days; i.e. the average euclidean norm between 7:30:05 and 7:30:10 am
% across all days, between 7:30:10 and 7:30:15, and between 7:30:15 and 7:30:20, etc. 
% (3) Calculate the mean of the metric for each sliding window of size 
% given by 'window'.
% (4) Find the window where the mean metric is at its minimum or maximum.
% (5) Return the mean metric of that window and the time of that window. 

% Initialize the varargin parser
p = inputParser;
addParameter(p, 'startDate', times(1), ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'positive'}) ...
);
addParameter(p, 'endDate', times(end), ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'positive'}) ...
);
addParameter(p, 'window', 15, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'integer', 'positive'}) ...
);
addParameter(p, 'getMinMax', 'min', ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
);
addParameter(p, 'select', 'all', ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
);
% Parse the variable arguments
parse(p,varargin{:});

% Force column vector
if size(metric, 1) == 1; metric = metric'; end
if size(times, 1) == 1; times = times'; end

% Cut the data into the requested segment if required
if p.Results.startDate ~= times(1) || p.Results.endDate ~= times(end) || ~strcmpi(p.Results.select, 'all')
    [metric, times] = selectDataUsingTime(metric, times, p.Results.startDate, p.Results.endDate, 'Select', p.Results.select);
end

% Return if the requested days are not available
if isempty(metric) 
    value     = NaN;
    timeOnset = 'na';
    metricPerWin = timeseries(NaN, 0);
    metricPerWin.TimeInfo.Units = 'days';
    return
end

% Define a vector indicating which samples are in the same epochs across all the days
windows = mod(round(times*24*60*(60/ACT.epoch)), 24*60*(60/ACT.epoch));
% Calculate the mean metric for each individual epoch of the day across all days
% The first index relates to the first epoch of the day, e.g. 0:00:00 - 0:00:05, etc.
% However if the number of unique windows is equal to the length of
% windows, there is only one day, and this step can be skipped.
if length(windows) ~= length(unique(windows)) % there are more windows than fit in one day
    metric = accumarray(windows+1, metric, [], @(x) mean(x, 'omitnan'));
    startTime = 0;
else % There are less windows than fit in a day
    startTime = times(1);
end

% Smooth the average metric across a rolling window of 'window' minutes
% (force odd-sized window)
oddWindow = (p.Results.window*60)/ACT.epoch;
if mod(oddWindow, 2) == 0 % its even so make it odd
    oddWindow = oddWindow+1;
end
metricPerWin = movmean([metric; metric], oddWindow, 'omitnan', 'Endpoints', 'discard');

% Return if there is not enough data
if isempty(metricPerWin) || oddWindow > length(metric)
    value     = NaN;
    timeOnset = 'na';
    metricPerWin = timeseries(NaN, 0);
    metricPerWin.TimeInfo.Units = 'days';
    return
end

% Crop the 'metricPerWin' back to its original size and add the discarded
% endpoint back to the beginning of the vector
metricPerWin = metricPerWin([length(metricPerWin)/2+1:(oddWindow-1)/2+length(metricPerWin)/2, 1:length(metricPerWin)/2]);

% Find the minute of the day where the metric is minimal or maximal
if strcmpi(p.Results.getMinMax, 'min')
    [value, idx] = min(metricPerWin);
elseif strcmpi(p.Results.getMinMax, 'max')
    [value, idx] = max(metricPerWin);
end
% if the min/.,ax value is not unique, find the largest bout and its middle index
if sum(metricPerWin == value) > 1
    [onset, duration] = getBouts(metricPerWin == value);
    [~, largestBout] = max(duration);
    idx = onset(largestBout) + ceil(duration(largestBout) / 2);
end

% The index 'idx' indicates the center of the window, so take away half of
% the 'oddWindow' lenght and check if it is not smaller than 1
idx = idx - (oddWindow-1)/2;
if idx < 1
    idx = length(metricPerWin) + idx;
end

times = startTime+(0:length(metricPerWin)-1)*ACT.epoch / (60*60*24);
metricPerWin = timeseries(metricPerWin, times);
metricPerWin.TimeInfo.Units = 'days';

% The unit of 'idx' is epochs, so 'idx*ACT.epoch' is seconds.
% Convert the seconds to a time string
timeOnset = datestr(times(idx),'HH:MM');

end
