function ACT = cic_statisticsDaily(ACT)

% ---------------------------------------------------------
% Create a new table
ACT.stats.daily = table();
for di = 1:ACT.ndays+1
    % ---------------------------------------------------------
    % Start and end dates from midnight to midnight
    startDate = datenum([datestr(ACT.xmin+(di-1), 'dd/mm/yyyy'), ' 00:00'], 'dd/mm/yyyy HH:MM');
    endDate   = datenum([datestr(ACT.xmin+di, 'dd/mm/yyyy'), ' 00:00'], 'dd/mm/yyyy HH:MM');
    % ---------------------------------------------------------
    % Extract this day's Euclidean Norm and insert NaNs for rejected segments
    [euclNormMinOne, timesEuclNorm] = selectDataUsingTime(ACT.metric.acceleration.euclNormMinOne.Data, ACT.metric.acceleration.euclNormMinOne.Time, startDate, endDate);
    if isempty(euclNormMinOne)
        break % if there is no more data, break out of this loop
    end
    euclNormMinOne(events2idx(ACT, timesEuclNorm, 'Label', 'reject')) = nan;
    annotate = selectDataUsingTime(ACT.analysis.annotate.Data, ACT.analysis.annotate.Time, startDate, endDate);
    % ---------------------------------------------------------
    % Day of the week
    ACT.stats.daily.date(di, 1) = cellstr(datestr(startDate, 'dd/mm/yyyy'));
    ACT.stats.daily.day(di, 1) = cellstr(datestr(startDate, 'ddd'));
    % ---------------------------------------------------------
    % Recording length in hours
    ACT.stats.daily.hoursValidData(di, 1) = sum(~isnan(euclNormMinOne)) * ACT.epoch / 3600;
    % ---------------------------------------------------------
    % Total time of rejected segments in hours
    ACT.stats.daily.hoursReject(di, 1) = sum(isnan(euclNormMinOne)) * ACT.epoch / 3600;
    % ---------------------------------------------------------
    % Average euclidean norm across entire day
    ACT.stats.daily.avEuclNorm(di, 1) = nanmean(euclNormMinOne);
    % ---------------------------------------------------------
    % Most and least activity in 5 hour moving windows
    % Note, this function returns datenum's which are converted to datestr at the end of this function
    [...
        ACT.stats.daily.maxEuclNormMovWin5h(di, 1), ...
        ACT.stats.daily.clockOnsetMaxEuclNormMovWin5h(di, 1), ...
        ACT.stats.daily.minEuclNormMovWin5h(di, 1), ...
        ACT.stats.daily.clockOnsetMinEuclNormMovWin5h(di, 1) ...
        ] = getM5L5(ACT, di);
    % ---------------------------------------------------------
    % How much time and activity was spend in moderate to vigorous activity in hours
    if any(ACT.analysis.annotate.Data ~= 0)
        ACT.stats.daily.hoursModVigAct(di,1) = sum(annotate >= 2) * ACT.epoch / 3600;
        ACT.stats.daily.avEuclNormModVigAct(di, 1) = nanmean(euclNormMinOne(annotate >= 2));
    else
        ACT.stats.daily.hoursModVigAct(di,1) = NaN;
        ACT.stats.daily.avEuclNormModVigAct(di, 1) = NaN;
    end
    % ---------------------------------------------------------
    % Indicates if participant slept across noon
    if isfield(ACT.analysis.settings, 'sleepWindowType')
        ACT.stats.daily.slpAcrossNoon(di, 1) = getSleepAcrossNoon(ACT, startDate, endDate);
    else
        ACT.stats.daily.slpAcrossNoon(di, 1) = nan;
    end
    % ---------------------------------------------------------
    % Average and variability of other data
    datatypes = ACT.display.order;
    for ti = 1:length(datatypes)
        fnames = fieldnames(ACT.metric.(datatypes{ti}));
        for fi = 1:length(fnames)
            % ---------------------------------------------------------
            % Extract this day's data and insert NaNs for rejected segments
            [data, times] = selectDataUsingTime(ACT.metric.(datatypes{ti}).(fnames{fi}).Data, ACT.metric.(datatypes{ti}).(fnames{fi}).Time, startDate, endDate);
            if isempty(data)
                data = nan;
                times = 0;
            end
            data(events2idx(ACT, times, 'Label', 'reject')) = nan;
            % ---------------------------------------------------------
            % Calculate average
            ACT.stats.daily.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi})])(di, 1) = nanmean(data);
            % ---------------------------------------------------------
            % Calculate the min, max and clock onset only if there is a whole 24 hour day
            if range(times)+ACT.epoch/(24*60*60) > 0.9999
                [...
                    ACT.stats.daily.(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(di, 1), ...
                    ACT.stats.daily.(['clockOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){di, 1}...
                    ] = getAvMetric(ACT, data, times, ...
                    'getMinMax', 'min', ...
                    'window',    30);
                [...
                    ACT.stats.daily.(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(di, 1), ...
                    ACT.stats.daily.(['clockOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){di, 1}...
                    ] = getAvMetric(ACT, data, times, ...
                    'getMinMax', 'max', ...
                    'window',    30);
            else
                ACT.stats.daily.(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(di, 1) = NaN;
                ACT.stats.daily.(['clockOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){di, 1} = 'na';
                ACT.stats.daily.(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(di, 1) = NaN;
                ACT.stats.daily.(['clockOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){di, 1} = 'na';
            end
        end
    end
end

% ---------------------------------------------------------
% Transform the clock onset max and min euclidean norm to date strings
idxNan = isnan(ACT.stats.daily.clockOnsetMaxEuclNormMovWin5h);
ACT.stats.daily.clockOnsetMaxEuclNormMovWin5h = cellstr(datestr(ACT.stats.daily.clockOnsetMaxEuclNormMovWin5h, 'dd/mm/yyyy HH:MM'));
ACT.stats.daily.clockOnsetMaxEuclNormMovWin5h(idxNan) = {'na'};

idxNan = isnan(ACT.stats.daily.clockOnsetMinEuclNormMovWin5h);
ACT.stats.daily.clockOnsetMinEuclNormMovWin5h = cellstr(datestr(ACT.stats.daily.clockOnsetMinEuclNormMovWin5h, 'dd/mm/yyyy HH:MM'));
ACT.stats.daily.clockOnsetMinEuclNormMovWin5h(idxNan) = {'na'};

end
