function [avEuclNormM5, clockOnsetM5, avEuclNormL5, clockOnsetL5] = getM5L5(ACT, di)

% initialize the output values as NaN's
avEuclNormM5 = NaN;
clockOnsetM5 = NaN;
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
timesToday    = timesToday(1:end-(window-1));

% Find M5, Most active 5 hours of the day
[avEuclNormM5, idx] = max(euclNormToday);
clockOnsetM5 = timesToday(idx);

% Next we want to find L5, but for this we need clock onset M5 from today
% and from yesterday. 
% -----
% If today's clock onset M5 is not available, you're out of luck, return
if isnan(clockOnsetM5)
    return
    % -----
    % If this is the first day, it is very unlikely that a complete sleep window was recorded after today's nightnight, so return
elseif di == 1
    return
    % -----
    % If this is not the first day, but yesterday's clock onset M5 is not available, use yesterday at 15:00 as the start date
elseif di > 1 && isnan(ACT.stats.daily.clockOnsetMaxEuclNormMovWin5h(di-1, 1))
    startDate = startDate - 9/24; % Start date was today's midnight, so take away 9 hours gives yesterday at 15:00
    endDate   = clockOnsetM5;
    % -----
    % Otherwise, all is good and we can use yesterday's clock offset M5 and and today's clock onset M5 
else
    startDate = ACT.stats.daily.clockOnsetMaxEuclNormMovWin5h(di-1, 1)+5/24; % yesterday's clock offset M5
    endDate   = clockOnsetM5;
end

% Now we're ready to find L5, Least active 5 hours of the day 

% Select the data and find the minimum in between
[euclNormToday, timesToday] = selectDataUsingTime(...
    ACT.metric.acceleration.euclNormMinOne.Data, ...
    ACT.metric.acceleration.euclNormMinOne.Time, ...
    startDate, ...
    endDate ...
    );

% The window must be smaller than available data in this day
if window >= length(euclNormToday)
    return
end

% Insert NaN's for rejected data
euclNormToday(events2idx(ACT, timesToday, 'Label', 'reject')) = nan;

% Calculate the mean Euclidean Norm for each rolling window
euclNormToday = movmean(euclNormToday, window, 'omitnan', 'Endpoints', 'discard');
timesToday    = timesToday(1:end-(window-1));

% Find the value and the time of the day where the metric is minimal
[avEuclNormL5, idx] = min(euclNormToday);
clockOnsetL5 = timesToday(idx);

end %EOF
