function [avActivityM10, clockOnsetM10, avActivityL5, clockOnsetL5] = getM10L5(ACT, di)

% initialize the output values as NaN's
avActivityM10 = NaN;
clockOnsetM10 = NaN;
avActivityL5 = NaN;
clockOnsetL5 = NaN;
    
% Start and end dates from midnight to midnight
startDate = datenum([datestr(ACT.xmin+(di-1), 'dd/mm/yyyy'), ' 00:00'], 'dd/mm/yyyy HH:MM');
endDate   = datenum([datestr(ACT.xmin+di, 'dd/mm/yyyy'), ' 00:00'], 'dd/mm/yyyy HH:MM');

% Extract Euclidean Norm for this day
[euclNormToday, timesToday] = selectDataUsingTime(...
    ACT.metric.acceleration.euclNormMinOne.Data, ...
    ACT.metric.acceleration.euclNormMinOne.Time, ...
    startDate, endDate);

% Insert NaN's for rejected data
euclNormToday(events2idx(ACT, timesToday, 'Label', 'reject')) = nan;

% There should be at least 21 hours of valid data (3 hours invalid: then return)
if range(timesToday) < (21/24)
    return
end

% If there is more than 3 hours of non-wear data, then return
if (sum(isnan(euclNormToday)) * ACT.epoch) / (24*60*60) > 3/24
    return
end

% Create a window of odd-length
window = round(10*3600/ACT.epoch); % 10 hour window
if mod(window, 2) == 0 % force odd window
    window = window+1;
end
% The window must be smaller than available data in this day
if window >= length(euclNormToday)
    return
end

% Calculate the mean Euclidean Norm for each rolling window
euclNormToday = movmean(euclNormToday, window, 'omitnan', 'Endpoints', 'discard');
timesToday    = timesToday(1:end-(window-1));

% Find M10, Most active 10 hours of the day
[avActivityM10, idx] = max(euclNormToday);
if isnan(avActivityM10)
    return
end
clockOnsetM10 = timesToday(idx);

% Next we want to find L5, but for this we need clock onset M10 from today
% and from yesterday. 
% -----
% If today's clock onset M10 is not available, you're out of luck, return
if isnan(clockOnsetM10)
    return
    % -----
    % If this is the first day, it is very unlikely that a complete sleep window was recorded after today's midnight, so return
elseif di == 1
    return
    % -----
    % If this is not the first day, but yesterday's clock onset M10 is not available, use yesterday at 15:00 as the start date
elseif di > 1 && isnan(ACT.stats.daily.clockOnsetMaxActivityMovWin10h(di-1, 1))
    startDate = startDate - 9/24; % Start date was today's midnight, so take away 9 hours gives yesterday at 15:00
    endDate   = clockOnsetM10 + 5/24; % Today's clock offset M10 plus 5 hours
    % -----
    % Otherwise, all is good and we can use yesterday's clock offset M10 and and today's clock onset M10
else
    startDate = ACT.stats.daily.clockOnsetMaxActivityMovWin10h(di-1, 1) + 5/24; % yesterday's clock offset M10 minus 5 hours
    endDate   = clockOnsetM10 + 5/24; % Today's clock offset M10 plus 5 hours
end

% Now we're ready to find L5, Least active 5 hours of the day 

% Select the data and find the minimum in between
[euclNormToday, timesToday] = selectDataUsingTime(...
    ACT.metric.acceleration.euclNormMinOne.Data, ...
    ACT.metric.acceleration.euclNormMinOne.Time, ...
    startDate, ...
    endDate ...
    );

% Create a window of odd-length
window = round(5*3600/ACT.epoch); % 5 hour window
if mod(window, 2) == 0 % force odd window
    window = window+1;
end
% The window must be smaller than available data in this day
if window >= length(euclNormToday)
    return
end

% Insert NaN's for rejected data
euclNormToday(events2idx(ACT, timesToday, 'Label', 'reject')) = nan;

% Calculate the mean Euclidean Norm for each rolling window
euclNormToday = movmean(euclNormToday, window, 'omitnan', 'Endpoints', 'discard');
timesToday = timesToday(1:end-(window-1));

% Find the value and the time of the day where the metric is minimal
[avActivityL5, idx] = min(euclNormToday);
clockOnsetL5 = timesToday(idx);

end %EOF
