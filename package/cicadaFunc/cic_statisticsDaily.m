function ACT = cic_statisticsDaily(ACT)
% ---------------------------------------------------------
% Do not show the warning that a new row is added to a table
warning('off', 'all')
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
    [actMetric, times] = selectDataUsingTime(ACT.metric.acceleration.euclNormMinOne.Data, ACT.metric.acceleration.euclNormMinOne.Time, startDate, endDate);
    if isempty(actMetric)
        % Try activity counts
        [actMetric, times] = selectDataUsingTime(ACT.metric.acceleration.counts.Data, ACT.metric.acceleration.counts.Time, startDate, endDate);
    end
    if isempty(actMetric)
        break % if there is no more data, break out of this loop
    end
    actMetric(events2idx(ACT, times, 'Label', 'reject')) = nan;
    % ---------------------------------------------------------
    % Day of the week
    ACT.stats.daily.date(di, 1) = cellstr(datestr(startDate, 'dd/mm/yyyy'));
    ACT.stats.daily.day(di, 1) = cellstr(datestr(startDate, 'ddd'));
    % ---------------------------------------------------------
    % Recording length in hours
    ACT.stats.daily.hoursValidData(di, 1) = sum(~isnan(actMetric)) * ACT.epoch / 3600;
    % ---------------------------------------------------------
    % Total time of rejected segments in hours
    ACT.stats.daily.hoursReject(di, 1) = sum(isnan(actMetric)) * ACT.epoch / 3600;
    % ---------------------------------------------------------
    % Average activity norm across entire day
    ACT.stats.daily.avActivity(di, 1) = mean(actMetric, 'omitnan');
    % ---------------------------------------------------------
    % Most (10h) and least (5h) activity
    % Note, this function returns datenum's which are converted to datestr at the end of this function
    [...
        ACT.stats.daily.maxActivityMovWin10h(di, 1), ...
        ACT.stats.daily.clockOnsetMaxActivityMovWin10h(di, 1), ...
        ACT.stats.daily.minActivityMovWin5h(di, 1), ...
        ACT.stats.daily.clockOnsetMinActivityMovWin5h(di, 1) ...
        ] = getM10L5(ACT, di);
    % ---------------------------------------------------------
    % Relative amplitude
    ACT.stats.daily.relAmpl(di, 1) = (ACT.stats.daily.maxActivityMovWin10h(di, 1) - ACT.stats.daily.minActivityMovWin5h(di, 1)) / (ACT.stats.daily.maxActivityMovWin10h(di, 1) + ACT.stats.daily.minActivityMovWin5h(di, 1));
    % ---------------------------------------------------------
    % How much time and activity was spend in moderate to vigorous activity in hours
    if isfield(ACT.analysis.annotate, 'acceleration')
        [annotate, timesAnnot] = selectDataUsingTime(...
            ACT.analysis.annotate.acceleration.Data, ...
            ACT.analysis.annotate.acceleration.Time, ...
            startDate, endDate);
        % insert NaNs for rejected segments
        annotate(events2idx(ACT, timesAnnot, 'Label', 'reject')) = nan;
        ACT.stats.daily.hoursSustInact(di,1) = sum(annotate == 0) * ACT.epoch / 3600;
        ACT.stats.daily.avActivitySustInact(di, 1) = mean(actMetric(annotate == 0), 'omitnan');
        ACT.stats.daily.hoursLowAct(di,1) = sum(annotate == 1) * ACT.epoch / 3600;
        ACT.stats.daily.avActivityLowAct(di, 1) = mean(actMetric(annotate == 1), 'omitnan');
        ACT.stats.daily.hoursLightAct(di,1) = sum(annotate == 2) * ACT.epoch / 3600;
        ACT.stats.daily.avActivityLightAct(di, 1) = mean(actMetric(annotate == 2), 'omitnan');
        ACT.stats.daily.hoursModVigAct(di,1) = sum(annotate >= 3) * ACT.epoch / 3600;
        ACT.stats.daily.avActivityModVigAct(di, 1) = mean(actMetric(annotate >= 3), 'omitnan');
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
    datatypes = fieldnames(ACT.metric);
    for ti = 1:length(datatypes)
        if strcmpi(datatypes{ti}, 'acceleration')
            continue
        end
        fnames = fieldnames(ACT.metric.(datatypes{ti}));
        for fi = 1:length(fnames)
            % ---------------------------------------------------------
            % Extract this days data and insert NaNs for rejected segments
            [data, times] = selectDataUsingTime(ACT.metric.(datatypes{ti}).(fnames{fi}).Data, ACT.metric.(datatypes{ti}).(fnames{fi}).Time, startDate, endDate);
            if isempty(data)
                data = nan;
                times = 0;
            end
            data(events2idx(ACT, times, 'Label', 'reject')) = nan;
            % ---------------------------------------------------------
            % Calculate average
            ACT.stats.daily.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi})])(di, 1) = mean(data, 'omitnan');
            % ---------------------------------------------------------
            % For light data, calculate the mean above 1 lux
            if strcmpi(datatypes{ti}, 'light')
                ACT.stats.daily.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'Gt1Lux'])(di, 1) = mean(data(data > 1), 'omitnan');
            end
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
        
        % ---------------------------------------------------------
        % If annotation of this datatype is available, calculate the time spent in each annotation level
        if isfield(ACT.analysis.annotate, datatypes{ti})
            % Extract the names of the levels
            if ~isfield(ACT.analysis.settings, [lower(datatypes{ti}), 'Levels'])
                warning('Did not find the annotation levels for ''%s'' metrics\n> In cic_statisticsDaily (line 104)', datatypes{ti})
                continue
            end
            levelsStr = ACT.analysis.settings.([lower(datatypes{ti}), 'Levels']);
            levelsData = unique(ACT.analysis.annotate.(datatypes{ti}).Data);
            if length(levelsStr) ~= length(levelsData)
                warning('Number of annotation levels for ''%s'' metrics in data does not match with the user-defined levels\n> In cic_statisticsDaily (line 110)', datatypes{ti})
                continue
            end
            [annotate, timesAnnot] = selectDataUsingTime(ACT.analysis.annotate.(datatypes{ti}).Data, ACT.analysis.annotate.(datatypes{ti}).Time, startDate, endDate);
            % insert NaNs for rejected segments
            annotate(events2idx(ACT, timesAnnot, 'Label', 'reject')) = nan;
            for li = 1:length(levelsData)
                ACT.stats.daily.(['hours', titleCase(levelsStr{li}), titleCase(datatypes{ti})])(di, 1) = (sum(annotate == levelsData(li)) * ACT.epoch) / 3600;
            end
        end
    end
end

% ---------------------------------------------------------
% Transform the clock onset max and min activity to date strings
idxNan = isnan(ACT.stats.daily.clockOnsetMaxActivityMovWin10h);
if all(idxNan)
    ACT.stats.daily.clockOnsetMaxActivityMovWin10h = repmat({'na'}, length(idxNan), 1);
else
    ACT.stats.daily.clockOnsetMaxActivityMovWin10h = cellstr(datestr(ACT.stats.daily.clockOnsetMaxActivityMovWin10h, 'dd/mm/yyyy HH:MM'));
    ACT.stats.daily.clockOnsetMaxActivityMovWin10h(idxNan) = {'na'};
end

idxNan = isnan(ACT.stats.daily.clockOnsetMinActivityMovWin5h);
if all(idxNan)
    ACT.stats.daily.clockOnsetMinActivityMovWin5h = repmat({'na'}, length(idxNan), 1);
else
    ACT.stats.daily.clockOnsetMinActivityMovWin5h = cellstr(datestr(ACT.stats.daily.clockOnsetMinActivityMovWin5h, 'dd/mm/yyyy HH:MM'));
    ACT.stats.daily.clockOnsetMinActivityMovWin5h(idxNan) = {'na'};
end
% ---------------------------------------------------------
% Turn back on the warnings
warning('on', 'all')

end
