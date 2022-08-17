function ACT = cic_statisticsAverage(ACT)

ACT.stats.average.all = table();
ACT.stats.average.week = table();
ACT.stats.average.weekend = table();

% ---------------------------------------------------------
% Extract Eucl Norm and Annotation and insert NaNs for rejected segments
euclNormMinOne = ACT.metric.acceleration.euclNormMinOne.Data;
euclNormMinOne(events2idx(ACT, ACT.metric.acceleration.euclNormMinOne.Time, 'Label', 'reject')) = nan;

% ---------------------------------------------------------
% Get indices of weekend days
idxWeekend = weekday(ACT.metric.acceleration.euclNormMinOne.Time) == 1 | weekday(ACT.metric.acceleration.euclNormMinOne.Time) == 7; % Sunday (1) or Saturday (7)

% ---------------------------------------------------------
% Hours rejected
ACT.stats.average.all.hoursReject = sum(ACT.stats.daily.hoursReject);
ACT.stats.average.week.hoursReject = sum(ACT.stats.daily.hoursReject(ismember(ACT.stats.daily.day, {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'})));
ACT.stats.average.weekend.hoursReject = sum(ACT.stats.daily.hoursReject(ismember(ACT.stats.daily.day, {'Sat', 'Sun'})));

% ---------------------------------------------------------
% Calculate inter daily stability and intra daily variablility
[ACT.stats.average.all.interDailyStability, ACT.stats.average.all.intraDailyVariability] = ggirDailyStabilityVariability(ACT);
[ACT.stats.average.week.interDailyStability, ACT.stats.average.week.intraDailyVariability] = ggirDailyStabilityVariability(ACT, 'week');
[ACT.stats.average.weekend.interDailyStability, ACT.stats.average.weekend.intraDailyVariability] = ggirDailyStabilityVariability(ACT, 'weekend');

% ---------------------------------------------------------
% Average and variability of Euclidean norm
ACT.stats.average.all.avEuclNorm = mean(euclNormMinOne, 'omitnan');
ACT.stats.average.week.avEuclNorm = mean(euclNormMinOne(~idxWeekend), 'omitnan');
ACT.stats.average.weekend.avEuclNorm = mean(euclNormMinOne(idxWeekend), 'omitnan');

% ---------------------------------------------------------
% Average euclidean norm in the most active 10 hours of the average day and its time
[ACT.stats.average.all.maxEuclNormMovWin10h, ACT.stats.average.all.clockOnsetMaxEuclNormMovWin10h] = ...
    getAvMetric(ACT, euclNormMinOne, ACT.metric.acceleration.euclNormMinOne.Time, ...
    'getMinMax', 'max', ...
    'window',    10*60);
[ACT.stats.average.week.maxEuclNormMovWin10h, ACT.stats.average.week.clockOnsetMaxEuclNormMovWin10h] = ...
    getAvMetric(ACT, euclNormMinOne, ACT.metric.acceleration.euclNormMinOne.Time, ...
    'getMinMax', 'max', ...
    'select', 'week', ...
    'window', 10*60);
[ACT.stats.average.weekend.maxEuclNormMovWin10h, ACT.stats.average.weekend.clockOnsetMaxEuclNormMovWin10h] = ...
    getAvMetric(ACT, euclNormMinOne, ACT.metric.acceleration.euclNormMinOne.Time, ...
    'getMinMax', 'max', ...
    'select', 'weekend', ...
    'window', 10*60);
% Average euclidean norm in the least active 5 hours of the average day and its time
[ACT.stats.average.all.minEuclNormMovWin5h, ACT.stats.average.all.clockOnsetMinEuclNormMovWin5h, ACT.analysis.average.all.euclNormMovWin5h] = ...
    getAvMetric(ACT, euclNormMinOne, ACT.metric.acceleration.euclNormMinOne.Time, ...
    'getMinMax', 'min', ...
    'window', 5*60);
[ACT.stats.average.week.minEuclNormMovWin5h, ACT.stats.average.week.clockOnsetMinEuclNormMovWin5h, ACT.analysis.average.week.euclNormMovWin5h] = ...
    getAvMetric(ACT, euclNormMinOne, ACT.metric.acceleration.euclNormMinOne.Time, ...
    'getMinMax', 'min', ...
    'select', 'week', ...
    'window', 5*60);
[ACT.stats.average.weekend.minEuclNormMovWin5h, ACT.stats.average.weekend.clockOnsetMinEuclNormMovWin5h, ACT.analysis.average.weekend.euclNormMovWin5h] = ...
    getAvMetric(ACT, euclNormMinOne, ACT.metric.acceleration.euclNormMinOne.Time, ...
    'getMinMax', 'min', ...
    'select', 'weekend', ...
    'window', 5*60);

% ---------------------------------------------------------
% Relative amplitude
ACT.stats.average.all.relAmpl = (ACT.stats.average.all.maxEuclNormMovWin10h - ACT.stats.average.all.minEuclNormMovWin5h) / (ACT.stats.average.all.maxEuclNormMovWin10h + ACT.stats.average.all.minEuclNormMovWin5h);
ACT.stats.average.week.relAmpl = (ACT.stats.average.week.maxEuclNormMovWin10h - ACT.stats.average.week.minEuclNormMovWin5h) / (ACT.stats.average.week.maxEuclNormMovWin10h + ACT.stats.average.week.minEuclNormMovWin5h);
ACT.stats.average.weekend.relAmpl = (ACT.stats.average.weekend.maxEuclNormMovWin10h - ACT.stats.average.weekend.minEuclNormMovWin5h) / (ACT.stats.average.weekend.maxEuclNormMovWin10h + ACT.stats.average.weekend.minEuclNormMovWin5h);

% ---------------------------------------------------------
% How much time and activity was spend in moderate to vigorous activity
if isfield(ACT.analysis.annotate, 'acceleration')
    annotate = ACT.analysis.annotate.acceleration.Data;
    annotate(events2idx(ACT, ACT.analysis.annotate.acceleration.Time, 'Label', 'reject')) = NaN;
    % All days
    ACT.stats.average.all.hoursSustInact = (sum(annotate == 0) * ACT.epoch / 3600) / (ACT.xmax-ACT.xmin); % hours per day
    ACT.stats.average.all.avEuclNormSustInact = mean(euclNormMinOne(annotate == 0), 'omitnan');
    ACT.stats.average.all.hoursLightAct = (sum(annotate == 2) * ACT.epoch / 3600) / (ACT.xmax-ACT.xmin); % hours per day
    ACT.stats.average.all.avEuclNormLightAct = mean(euclNormMinOne(annotate == 2), 'omitnan');
    ACT.stats.average.all.hoursModVigAct = (sum(annotate >= 3) * ACT.epoch / 3600) / (ACT.xmax-ACT.xmin); % hours per day
    ACT.stats.average.all.avEuclNormModVigAct = mean(euclNormMinOne(annotate >= 3), 'omitnan');
    % Week days
    ACT.stats.average.week.hoursSustInact = sum(annotate(~idxWeekend) == 0) / ((sum(~idxWeekend)) / 24); % # hours per day
    ACT.stats.average.week.avEuclNormSustInact = mean(euclNormMinOne(annotate == 0 & ~idxWeekend), 'omitnan');
    ACT.stats.average.week.hoursLightAct = sum(annotate(~idxWeekend) == 2) / ((sum(~idxWeekend)) / 24); % # hours per day
    ACT.stats.average.week.avEuclNormLightAct = mean(euclNormMinOne(annotate == 2 & ~idxWeekend), 'omitnan');
    ACT.stats.average.week.hoursModVigAct = sum(annotate(~idxWeekend) >= 3) / ((sum(~idxWeekend)) / 24); % # hours per day
    ACT.stats.average.week.avEuclNormModVigAct = mean(euclNormMinOne(annotate >= 3 & ~idxWeekend), 'omitnan');
    % Weekend days
    ACT.stats.average.weekend.hoursSustInact = sum(annotate(idxWeekend) == 0) / ((sum(idxWeekend)) / 24);
    ACT.stats.average.weekend.avEuclNormSustInact = mean(euclNormMinOne(annotate == 0 & idxWeekend), 'omitnan');
    ACT.stats.average.weekend.hoursLightAct = sum(annotate(idxWeekend) == 2) / ((sum(idxWeekend)) / 24);
    ACT.stats.average.weekend.avEuclNormLightAct = mean(euclNormMinOne(annotate == 2 & idxWeekend), 'omitnan');
    ACT.stats.average.weekend.hoursModVigAct = sum(annotate(idxWeekend) >= 3) / ((sum(idxWeekend)) / 24);
    ACT.stats.average.weekend.avEuclNormModVigAct = mean(euclNormMinOne(annotate >= 3 & idxWeekend), 'omitnan');
else
    for select = {'all', 'week', 'weekend'}
        ACT.stats.average.(select{:}).hoursSustInact = NaN;
        ACT.stats.average.(select{:}).avEuclNormSustInact = NaN;
        ACT.stats.average.(select{:}).hoursLightAct = NaN;
        ACT.stats.average.(select{:}).avEuclNormLightAct = NaN;
        ACT.stats.average.(select{:}).hoursModVigAct = NaN;
        ACT.stats.average.(select{:}).avEuclNormModVigAct = NaN;
    end
end

% ---------------------------------------------------------
% Average and variability of other data
datatypes = fieldnames(ACT.metric);
for di = 1:length(datatypes)
    if strcmpi(datatypes{di}, 'acceleration')
        continue
    end
    fnames = fieldnames(ACT.metric.(datatypes{di}));
    for select = {'all', 'week', 'weekend'}
        for fi = 1:length(fnames)
            % ---------------------------------------------------------
            % Extract the data and insert NaNs for rejected data
            [data, times] = selectDataUsingTime(ACT.metric.(datatypes{di}).(fnames{fi}).Data, ACT.metric.(datatypes{di}).(fnames{fi}).Time, ACT.xmin, ACT.xmax, 'Select', select{:});
            if isempty(data)
                data = nan;
                times = 0;
            end
            data(events2idx(ACT, times, 'Label', 'reject')) = nan;
            % ---------------------------------------------------------
            % Calculate average
            ACT.stats.average.(select{:}).(['av', titleCase(datatypes{di}), titleCase(fnames{fi})]) = mean(data, 'omitnan');
            % ---------------------------------------------------------
            % For light data, calculate the mean above 1 lux
            if strcmpi(datatypes{di}, 'light')
                ACT.stats.average.(select{:}).(['av', titleCase(datatypes{di}), titleCase(fnames{fi}), 'Gt1Lux']) = mean(data(data > 1), 'omitnan');
            end
            % ---------------------------------------------------------
            % Calculate the min, max and clock onset across all days, but only if there is a whole 24 hour day
            if range(times)+ACT.epoch/(24*60*60) > 0.9999
                [...
                    ACT.stats.average.(select{:}).(['min', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']), ...
                    ACT.stats.average.(select{:}).(['clockOnsetMin', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']), ...
                    ACT.analysis.average.(select{:}).([lower(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m'])] = ...
                    getAvMetric(ACT, data, times, ...
                    'getMinMax', 'min', ...
                    'window',    30);
                [...
                    ACT.stats.average.(select{:}).(['max', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']), ...
                    ACT.stats.average.(select{:}).(['clockOnsetMax', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m'])] = ...
                    getAvMetric(ACT, data, times, ...
                    'getMinMax', 'max', ...
                    'window',    30);
            else
                ACT.stats.average.(select{:}).(['min', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']) = NaN;
                ACT.stats.average.(select{:}).(['clockOnsetMin', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']) = 'na';
                ACT.stats.average.(select{:}).(['max', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']) = NaN;
                ACT.stats.average.(select{:}).(['clockOnsetMax', titleCase(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']) = 'na';
                ACT.analysis.average.(select{:}).([lower(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']) = timeseries(NaN, 0);
                ACT.analysis.average.(select{:}).([lower(datatypes{di}), titleCase(fnames{fi}), 'MovWin30m']).TimeInfo.Units = 'days';
            end
        end
        % ---------------------------------------------------------
        % If annotation of this datatype is available, calculate the time spent in each annotation level
        if isfield(ACT.analysis.annotate, datatypes{di})
            % Extract the names of the levels
            if ~isfield(ACT.analysis.settings, [lower(datatypes{di}), 'Levels'])
                warning('Did not find the annotation levels for ''%s'' metrics\n> In cic_statisticsAverage (line 147)', datatypes{di})
                continue
            end
            levelsStr = ACT.analysis.settings.([lower(datatypes{di}), 'Levels']);
            levelsData = unique(ACT.analysis.annotate.(datatypes{di}).Data);
            if length(levelsStr) ~= length(levelsData)
                warning('Number of annotation levels for ''%s'' metrics in data does not match with the user-defined levels\n> In cic_statisticsAverage (line 153)', datatypes{di})
                continue
            end
            [annotate, times] = selectDataUsingTime(ACT.analysis.annotate.(datatypes{di}).Data, ACT.analysis.annotate.(datatypes{di}).Time, ACT.xmin, ACT.xmax, 'Select', select{:});
            % insert NaNs for rejected segments
            annotate(events2idx(ACT, times, 'Label', 'reject')) = nan;
            for li = 1:length(levelsData)
                ACT.stats.average.(select{:}).(['hours', titleCase(levelsStr{li}), titleCase(datatypes{di})]) = sum(annotate == levelsData(li)) / ((length(times)) / 24);
            end
        end
    end
end
% ---------------------------------------------------------
% If a sleep window type exists, continue to calculate average sleep statistics
if isfield(ACT.analysis.settings, 'sleepWindowType') && isfield(ACT.stats, 'sleep')
    % ---------------------------------------------------------
    % Number of sleep and nap windows
    idxWeek = ismember(ACT.stats.sleep.actigraphy.dayLightsOn, {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'});
    ACT.stats.average.all.slpCount = sum(strcmpi(ACT.stats.sleep.actigraphy.slpType, 'night'));
    ACT.stats.average.week.slpCount = sum(strcmpi(ACT.stats.sleep.actigraphy.slpType(idxWeek), 'night'));
    ACT.stats.average.weekend.slpCount = sum(strcmpi(ACT.stats.sleep.actigraphy.slpType(~idxWeek), 'night'));
    ACT.stats.average.all.napCount = sum(strcmpi(ACT.stats.sleep.actigraphy.slpType, 'nap'));
    ACT.stats.average.week.napCount = sum(strcmpi(ACT.stats.sleep.actigraphy.slpType(idxWeek), 'nap'));
    ACT.stats.average.weekend.napCount = sum(strcmpi(ACT.stats.sleep.actigraphy.slpType(~idxWeek), 'nap'));
    % ---------------------------------------------------------
    % Sleep across noon values
    ACT.stats.average.all.slpAcrossNoon = sum(ACT.stats.daily.slpAcrossNoon);
    ACT.stats.average.week.slpAcrossNoon = sum(ACT.stats.daily.slpAcrossNoon(ismember(ACT.stats.daily.day, {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'})));
    ACT.stats.average.weekend.slpAcrossNoon = sum(ACT.stats.daily.slpAcrossNoon(ismember(ACT.stats.daily.day, {'Sat', 'Sun'})));
else
    return
end

% ---------------------------------------------------------
% Extract average sleep statistics for each day-type
for select = {'all', 'week', 'weekend'}
    % ---------------------------------------------------------
    % Get which days are part of this day-type
    switch select{:}
        case 'all'
            selectDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
        case 'week'
            selectDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};
        case 'weekend'
            selectDays = {'Sat', 'Sun'};
    end
    
    % ---------------------------------------------------------
    % Check whether sleep windows and annotation are available to calculate average sleep variables
    
    % ---------------------------------------------------------
    % Case 1, sleep windows and annotation are both available
    if isfield(ACT.analysis.settings, 'sleepWindowType') && isfield(ACT.analysis.annotate, 'acceleration')
        % ---------------------------------------------------------
        % Actigraphy
        idx = ismember(ACT.stats.sleep.actigraphy.dayLightsOn, selectDays) & strcmpi(ACT.stats.sleep.actigraphy.slpType, 'night');
        ACT.stats.average.(select{:}).avClockLightsOutAct    = getAvEventTime(ACT, 'onset', 'Label', 'sleepWindow', 'Type', ACT.analysis.settings.sleepWindowType, 'Select', select{:});
        ACT.stats.average.(select{:}).avClockLightsOnAct     = getAvEventTime(ACT, 'offset', 'Label', 'sleepWindow', 'Type', ACT.analysis.settings.sleepWindowType, 'Select', select{:});
        ACT.stats.average.(select{:}).avClockSlpOnsetAct     = getAvEventTime(ACT, 'onset', 'Label', 'sleepPeriod', 'Type', 'actigraphy', 'Select', select{:});
        ACT.stats.average.(select{:}).avClockMidSleepAct     = getAvEventTime(ACT, 'midpoint', 'Label', 'sleepPeriod', 'Type', 'actigraphy', 'Select', select{:});
        ACT.stats.average.(select{:}).avClockFinAwakeAct     = getAvEventTime(ACT, 'offset', 'Label', 'sleepPeriod', 'Type', 'actigraphy', 'Select', select{:});
        ACT.stats.average.(select{:}).avSlpOnsetLatAct       = mean(ACT.stats.sleep.actigraphy.slpOnsetLat(idx), 'omitnan');
        ACT.stats.average.(select{:}).avAwakeningAct         = mean(ACT.stats.sleep.actigraphy.nAwakening(idx), 'omitnan');
        ACT.stats.average.(select{:}).avWakeAfterSlpOnsetAct = mean(ACT.stats.sleep.actigraphy.wakeAfterSlpOnset(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSnoozeTimeAct        = mean(ACT.stats.sleep.actigraphy.snoozeTime(idx), 'omitnan');
        ACT.stats.average.(select{:}).avTotSlpTimeAct        = mean(ACT.stats.sleep.actigraphy.totSlpTime(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpPeriodAct         = mean(ACT.stats.sleep.actigraphy.slpPeriod(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpWindowAct         = mean(ACT.stats.sleep.actigraphy.slpWindow(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpEffSlpTimeAct     = mean(ACT.stats.sleep.actigraphy.slpEffSlpTime(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpEffSlpPeriodAct   = mean(ACT.stats.sleep.actigraphy.slpEffSlpPeriod(idx), 'omitnan');
        ACT.stats.average.(select{:}).avAwakePerHourAct      = mean(ACT.stats.sleep.actigraphy.awakePerHour(idx), 'omitnan');
        
        % ---------------------------------------------------------
        % Case 2, sleep windows are available but no annotation
    elseif isfield(ACT.analysis.settings, 'sleepWindowType') && ~isfield(ACT.analysis.annotate, 'acceleration')
        % ---------------------------------------------------------
        % Actigraphy
        ACT.stats.average.(select{:}).avClockLightsOutAct    = getAvEventTime(ACT, 'onset', 'Label', 'sleepWindow', 'Type', ACT.analysis.settings.sleepWindowType, 'Select', select{:});
        ACT.stats.average.(select{:}).avClockLightsOnAct     = getAvEventTime(ACT, 'offset', 'Label', 'sleepWindow', 'Type', ACT.analysis.settings.sleepWindowType, 'Select', select{:});
        ACT.stats.average.(select{:}).avClockSlpOnsetAct     = 'na';
        ACT.stats.average.(select{:}).avClockMidSleepAct     = 'na';
        ACT.stats.average.(select{:}).avClockFinAwakeAct     = 'na';
        ACT.stats.average.(select{:}).avSlpOnsetLatAct       = NaN;
        ACT.stats.average.(select{:}).avAwakeningAct         = NaN;
        ACT.stats.average.(select{:}).avWakeAfterSlpOnsetAct = NaN;
        ACT.stats.average.(select{:}).avSnoozeTimeAct        = NaN;
        ACT.stats.average.(select{:}).avTotSlpTimeAct        = NaN;
        ACT.stats.average.(select{:}).avSlpPeriodAct         = NaN;
        ACT.stats.average.(select{:}).avSlpWindowAct         = NaN;
        ACT.stats.average.(select{:}).avSlpEffSlpTimeAct     = NaN;
        ACT.stats.average.(select{:}).avSlpEffSlpPeriodAct   = NaN;
        ACT.stats.average.(select{:}).avAwakePerHourAct      = NaN;
        
        % ---------------------------------------------------------
        % Case 3, sleep windows are not available (does not matter if annotation is done or not)
    else
        % ---------------------------------------------------------
        % Actigraphy
        ACT.stats.average.(select{:}).avClockLightsOutAct    = 'na';
        ACT.stats.average.(select{:}).avClockLightsOnAct     = 'na';
        ACT.stats.average.(select{:}).avClockSlpOnsetAct     = 'na';
        ACT.stats.average.(select{:}).avClockMidSleepAct     = 'na';
        ACT.stats.average.(select{:}).avClockFinAwakeAct     = 'na';
        ACT.stats.average.(select{:}).avSlpOnsetLatAct       = NaN;
        ACT.stats.average.(select{:}).avAwakeningAct         = NaN;
        ACT.stats.average.(select{:}).avWakeAfterSlpOnsetAct = NaN;
        ACT.stats.average.(select{:}).avSnoozeTimeAct        = NaN;
        ACT.stats.average.(select{:}).avTotSlpTimeAct        = NaN;
        ACT.stats.average.(select{:}).avSlpPeriodAct         = NaN;
        ACT.stats.average.(select{:}).avSlpWindowAct         = NaN;
        ACT.stats.average.(select{:}).avSlpEffSlpTimeAct     = NaN;
        ACT.stats.average.(select{:}).avSlpEffSlpPeriodAct   = NaN;
        ACT.stats.average.(select{:}).avAwakePerHourAct      = NaN;
    end
    
    % ---------------------------------------------------------
    % Sleep Diary, if it exists
    if isfield(ACT.stats.sleep, 'sleepDiary')
        % Make sure each sleep diary entry aligns with one unique actigraphy sleep window, otherwise we cannot compare the two
        ACT.stats.sleep.compareAverage = true; % assume all is good
        idxNight = find(strcmpi(ACT.stats.sleep.actigraphy.slpType, 'night'));
        if length(idxNight) ~= size(ACT.stats.sleep.sleepDiary, 1)
            ACT.stats.sleep.compareAverage = false;
            continue
        end
        onset  = datenum(ACT.stats.sleep.sleepDiary.clockLightsOut, 'dd/mm/yyyy HH:MM');
        offset = datenum(ACT.stats.sleep.sleepDiary.clockLightsOn, 'dd/mm/yyyy HH:MM');
        for si = 1:length(idxNight)
            idx = ...
                (...
                onset >= datenum(ACT.stats.sleep.actigraphy.clockLightsOut{idxNight(si)}, 'dd/mm/yyyy HH:MM') & ...
                onset <= datenum(ACT.stats.sleep.actigraphy.clockLightsOn{idxNight(si)}, 'dd/mm/yyyy HH:MM') ...
                ) | (...
                offset >= datenum(ACT.stats.sleep.actigraphy.clockLightsOut{idxNight(si)}, 'dd/mm/yyyy HH:MM') & ...
                offset <= datenum(ACT.stats.sleep.actigraphy.clockLightsOn{idxNight(si)}, 'dd/mm/yyyy HH:MM') ...
                ) | (...
                onset <= datenum(ACT.stats.sleep.actigraphy.clockLightsOut{idxNight(si)}, 'dd/mm/yyyy HH:MM') & ...
                offset >= datenum(ACT.stats.sleep.actigraphy.clockLightsOn{idxNight(si)}, 'dd/mm/yyyy HH:MM') ...
                );
            if sum(idx) ~= 1
                ACT.stats.sleep.compareAverage = false;
                break
            end
        end
        if ~ACT.stats.sleep.compareAverage
            continue
        end
        % All good, the size of actigraphy and diary sleep windows are the same, and each diary entry aligns with one unique actigraphy sleep window
        idx = ismember(ACT.stats.sleep.sleepDiary.dayLightsOn, selectDays);
        ACT.stats.average.(select{:}).avClockLightsOutDiary    = getAvEventTime(ACT, 'onset',  'Label', 'sleepWindow', 'Type', 'sleepDiary', 'Select', select{:});
        ACT.stats.average.(select{:}).avClockLightsOnDiary     = getAvEventTime(ACT, 'offset', 'Label', 'sleepWindow', 'Type', 'sleepDiary', 'Select', select{:});
        ACT.stats.average.(select{:}).avClockSlpOnsetDiary     = getAvEventTime(ACT, 'onset',  'Label', 'sleepPeriod', 'Type', 'sleepDiary', 'Select', select{:});
        ACT.stats.average.(select{:}).avClockMidSleepDiary     = getAvEventTime(ACT, 'midpoint',  'Label', 'sleepPeriod', 'Type', 'sleepDiary', 'Select', select{:});
        ACT.stats.average.(select{:}).avClockFinAwakeDiary     = getAvEventTime(ACT, 'offset', 'Label', 'sleepPeriod', 'Type', 'sleepDiary', 'Select', select{:});
        ACT.stats.average.(select{:}).avSlpOnsetLatDiary       = mean(ACT.stats.sleep.sleepDiary.slpOnsetLat(idx), 'omitnan');
        ACT.stats.average.(select{:}).avAwakeningDiary         = mean(ACT.stats.sleep.sleepDiary.nAwakening(idx), 'omitnan');
        ACT.stats.average.(select{:}).avWakeAfterSlpOnsetDiary = mean(ACT.stats.sleep.sleepDiary.wakeAfterSlpOnset(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSnoozeTimeDiary        = mean(ACT.stats.sleep.sleepDiary.snoozeTime(idx), 'omitnan');
        ACT.stats.average.(select{:}).avTotSlpTimeDiary        = mean(ACT.stats.sleep.sleepDiary.totSlpTime(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpPeriodDiary         = mean(ACT.stats.sleep.sleepDiary.slpPeriod(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpWindowDiary         = mean(ACT.stats.sleep.sleepDiary.slpWindow(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpEffSlpTimeDiary     = mean(ACT.stats.sleep.sleepDiary.slpEffSlpTime(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSlpEffSlpPeriodDiary   = mean(ACT.stats.sleep.sleepDiary.slpEffSlpPeriod(idx), 'omitnan');
        ACT.stats.average.(select{:}).avAwakePerHourDiary      = mean(ACT.stats.sleep.sleepDiary.awakePerHour(idx), 'omitnan');
        ACT.stats.average.(select{:}).avSleepTimeMismatch      = ACT.stats.average.(select{:}).avTotSlpTimeDiary - ACT.stats.average.(select{:}).avTotSlpTimeAct;
        ACT.stats.average.(select{:}).avSleepPeriodMismatch    = ACT.stats.average.(select{:}).avSlpPeriodDiary - ACT.stats.average.(select{:}).avSlpPeriodAct;
    end
end

end