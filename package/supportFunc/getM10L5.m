function [avEuclNormM10, clockOnsetM10, avEuclNormL5, clockOnsetL5] = getM10L5(ACT, di)

% initialize the output values as NaN's
avEuclNormM10 = NaN;
clockOnsetM10 = NaN;
avEuclNormL5 = NaN;
clockOnsetL5 = NaN;
    
% Start and end dates from midnight to midnight
startDate = datenum([datestr(ACT.xmin+(di-1), 'dd/mm/yyyy'), ' 00:00'], 'dd/mm/yyyy HH:MM');
endDate   = datenum([datestr(ACT.xmin+di, 'dd/mm/yyyy'), ' 00:00'], 'dd/mm/yyyy HH:MM');

% Extract Euclidean Norm for this day
[euclNormToday, timesToday] = selectDataUsingTime(...
    ACT.metric.acceleration.euclNormMinOne.Data, ...
    ACT.metric.acceleration.euclNormMinOne.Time, ...
    startDate, endDate);
% If there is less than 12 hours of data in this day, then return
if range(timesToday) < (12/24)
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

% Insert NaN's for rejected data
euclNormToday(events2idx(ACT, timesToday, 'Label', 'reject')) = nan;

% Calculate the mean Euclidean Norm for each rolling window
euclNormToday = movmean(euclNormToday, window, 'omitnan', 'Endpoints', 'discard');
timesToday    = timesToday(1:end-(window-1));

% Find M10, Most active 10 hours of the day
[avEuclNormM10, idx] = max(euclNormToday);
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
elseif di > 1 && isnan(ACT.stats.daily.clockOnsetMaxEuclNormMovWin10h(di-1, 1))
    startDate = startDate - 9/24; % Start date was today's midnight, so take away 9 hours gives yesterday at 15:00
    endDate   = clockOnsetM10;
    % -----
    % Otherwise, all is good and we can use yesterday's clock offset M10 and and today's clock onset M10
else
    startDate = ACT.stats.daily.clockOnsetMaxEuclNormMovWin10h(di-1, 1)+10/24; % yesterday's clock offset M10
    endDate   = clockOnsetM10;
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
[avEuclNormL5, idx] = min(euclNormToday);
clockOnsetL5 = timesToday(idx);

end %EOF