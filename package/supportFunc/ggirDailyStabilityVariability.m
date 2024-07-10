function [interDailyStab, intraDailyVar] = ggirDailyStabilityVariability(ACT, varargin)

if nargin == 1
    select = 'all';
else
    select = varargin{:};
end

% initialize output variables as NaN's
interDailyStab = NaN;
intraDailyVar  = NaN;

% Create Euclidean Norm in 30 second epochs
if isfield(ACT.data.acceleration, 'x')
    epoch = 30; % seconds
    step  = 1/(24*60*60/epoch);
    times = ACT.xmin:step:ACT.xmax;
    actMetric = sqrt(ACT.data.acceleration.x.Data .^2 + ACT.data.acceleration.y.Data .^2 + ACT.data.acceleration.z.Data .^2) - 1;
    actMetric(actMetric < 0) = 0;
    actMetric = averagePerWindow(actMetric, ACT.srate, epoch);
else
    actMetric = ACT.metric.acceleration.counts.Data;
    times = ACT.metric.acceleration.counts.Time;
end
% Select data from first to last midnight
%%% IMPORTANT NOTE %%%
% My implementation results in a difference with the implementation of GGIR:
% In GGIR, the midnight indices are determined by 'timestamp' in 'metalong', 
% which has 15-minute epochs by default, so the first and last indices of
% selected timeseries with shorter epoch lengths, e.g. 30-seconds as we use
% in this function, are at 00:15 am, not 00:00 am. Here I define midnight 
% indices with the appropriate timeseries vector to select 00:00 am.
switch select
    case 'week'
        [actMetric, times] = selectDataUsingTime( ...
            actMetric, ...
            times, ...
            ceil(ACT.xmin), floor(ACT.xmax), ...
            'Select', 'week');
    case 'weekend'
        [actMetric, times] = selectDataUsingTime( ...
            actMetric, ...
            times, ...
            ceil(ACT.xmin), floor(ACT.xmax), ...
            'Select', 'weekend');
    otherwise
        [actMetric, times] = selectDataUsingTime( ...
            actMetric, ...
            times, ...
            ceil(ACT.xmin), floor(ACT.xmax));
end

% Check if we have enough data (3 days), if not return the function
if range(times) < 3
    return
end

% Copy the data over so we can insert NaN's for non-wear periods
idx = events2idx(ACT, times, 'Label', 'reject');
actMetric(idx) = NaN;

% Vector to indicate which hour each sample belongs to
hour = ceil((30:30:30*length(actMetric))./3600)';

% Calculate the mean Euclidean Norm for each hour of the recording
actMetricPerHour = accumarray(hour, actMetric, [], @(x) mean(x, 'omitnan'));

% Redefine the 'hour' vector to denote each hour of the day (0 - 23)
hour = mod(unique(hour), 24);

% For each hour of the day, calulate the mean euclidean norm
actMetricPerHour  = accumarray(hour+1, actMetricPerHour, [], @(x) mean(x, 'omitnan'));

% Calculate the grand average euclidean norm
grandMeanActMetric = mean(actMetricPerHour, 'omitnan');

% Stability, lower values indicate less synchronization with the 24 hour zeitgeber
interDailyStab = (sum((actMetricPerHour - grandMeanActMetric).^2, 'omitnan') * length(actMetric)) / (length(actMetricPerHour) * sum((actMetric-grandMeanActMetric).^2, 'omitnan'));
% Variability: higher values indicate more variability within days (fragmentation)
intraDailyVar = (sum(diff(actMetric).^2, 'omitnan') * length(actMetric)) / ((length(actMetric)-1) * sum((grandMeanActMetric-actMetric).^2, 'omitnan'));

end