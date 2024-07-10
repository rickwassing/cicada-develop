function ACT = cic_statisticsSleep(ACT, eventType)
% ---------------------------------------------------------
% Extract the relevant events
switch eventType
    case 'actigraphy'
        slpWindowType = ACT.analysis.settings.sleepWindowType;
        slpPeriodType = 'actigraphy';
        % Also extract nap windows
        doNapWindows = true;
    case 'sleepDiary'
        slpWindowType = 'sleepDiary';
        slpPeriodType = 'sleepDiary';
        % Do not extract nap windows
        doNapWindows = false;
end
slpWindows = selectEventsUsingTime(ACT.analysis.events, ACT.xmin, ACT.xmax, ...
    'Label', 'sleepWindow', ...
    'Type', slpWindowType);
if doNapWindows
    napWindows = selectEventsUsingTime(ACT.analysis.events, ACT.xmin, ACT.xmax, ...
        'Label', 'napWindow');
end
% ---------------------------------------------------------
% Check if there are any events, if not, return
if isempty(slpWindows)
    if isfield(ACT.stats, 'sleep')
        if isfield(ACT.stats.sleep, eventType)
            ACT.stats.sleep = rmfield(ACT.stats.sleep, eventType);
        end
        if isempty(fieldnames(ACT.stats.sleep))
            ACT.stats = rmfield(ACT.stats, 'sleep');
        end
    end
    return
end
% Get sleep event stats
ACT.stats.sleep.(eventType) = parseSleepEvents(ACT, slpWindows, eventType, 'sleep', 'sleepPeriod', slpPeriodType);
% Get wake event stats
res = parseWakeEvents(ACT, slpWindows);
vartypes = varfun(@class, ACT.stats.sleep.(eventType), 'OutputFormat', 'cell');
tmp = table('Size', [size(res, 1), size(ACT.stats.sleep.(eventType), 2)], ...
    'VariableTypes', vartypes, ...
    'VariableNames', ACT.stats.sleep.(eventType).Properties.VariableNames);
for i = 1:size(tmp, 2)
    switch vartypes{i}
        case 'cell'
            tmp{:, i} = repmat({'na'}, size(res, 1), 1);
        case 'double'
            tmp{:, i} = nan(size(res, 1), 1);
    end
end
for i = 1:length(res.Properties.VariableNames)
    tmp.(res.Properties.VariableNames{i}) = res.(res.Properties.VariableNames{i});
end
% Append
ACT.stats.sleep.(eventType) = [ACT.stats.sleep.(eventType); tmp];
% Get nap stats if required
if doNapWindows && ~isempty(napWindows)
    napStats = parseSleepEvents(ACT, napWindows, eventType, 'nap', 'napPeriod', slpPeriodType);
    ACT.stats.sleep.(eventType) = [ACT.stats.sleep.(eventType); napStats];
end
% Sort by event onset
[~, idx] = sort(datenum(ACT.stats.sleep.(eventType).clockEventOnset, 'dd/mm/yyyy HH:MM'));
ACT.stats.sleep.(eventType) = ACT.stats.sleep.(eventType)(idx, :);

    function res = parseSleepEvents(ACT, events, eventType, sleepType, slpPeriodLabel, slpPeriodType)
        % ---------------------------------------------------------
        % Create a new table
        res = table();
        % ---------------------------------------------------------
        % Indicator what type of sleep this is, night or nap
        res.type = repmat({sleepType}, size(events,1), 1);
        % ---------------------------------------------------------
        % Counter for the number of nights
        res.count = (1:size(events, 1))';
        % ---------------------------------------------------------
        % Indicator how the event was created, by algorithm or manual
        res.eventOrigin = events.type;
        % ---------------------------------------------------------
        % Indicator whether the sleep was a week or weekend night
        % Note, Fri-Sat and Sat-Sun are weekend nights, all other nights are weeknights
        res.dayEventOnset = cellstr(datestr(events.onset, 'ddd'));
        res.dayEventOffset = cellstr(datestr(events.onset + events.duration, 'ddd'));
        % ---------------------------------------------------------
        % Eyes closed and open date and time
        res.clockEventOnset = cellstr(datestr(events.onset, 'dd/mm/yyyy HH:MM'));
        res.clockEventOffset = cellstr(datestr(events.onset + events.duration, 'dd/mm/yyyy HH:MM'));
        res.eventDuration = (events.duration)*24*60;
        % ---------------------------------------------------------
        % For each sleep window check the sleep period and waso events
        for s = 1:size(events,1)
            % ---------------------------------------------------------
            % Select sleep period events for this night
            slpPeriods = selectEventsUsingTime(ACT.analysis.events, events.onset(s), events.onset(s)+events.duration(s), ...
                'Label', slpPeriodLabel, ...
                'Type', slpPeriodType);
            % ---------------------------------------------------------
            % If there is no sleep period then continue to the next sleep window
            if isempty(slpPeriods)
                res.clockSlpOnset{s, 1} = 'na';
                res.clockMidSleep{s, 1} = 'na';
                res.clockFinAwake{s, 1} = 'na';
                res.slpOnsetLat(s, 1) = NaN;
                res.nAwakening(s, 1) = NaN;
                res.wakeAfterSlpOnset(s, 1) = NaN;
                res.snoozeTime(s, 1) = NaN;
                res.totSlpTime(s, 1) = NaN;
                res.slpPeriod(s, 1) = NaN;
                res.slpWindow(s, 1) = NaN;
                res.slpEffSlpTime(s, 1) = NaN;
                res.slpEffSlpPeriod(s, 1) = NaN;
                % ---------------------------------------------------------
                % Average and variability of other data
                datatypes = fieldnames(ACT.metric);
                for ti = 1:length(datatypes)
                    fnames = fieldnames(ACT.metric.(datatypes{ti}));
                    for fi = 1:length(fnames)
                        res.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi})])(s, 1) = nan;
                        if strcmpi(datatypes{ti}, 'light')
                            res.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'Gt1Lux'])(s, 1) = nan;
                        end
                    end
                end
                continue
            end
            % ---------------------------------------------------------
            % make sure there is one and only one sleep period within this sleep window
            slpPeriods = slpPeriods(1, :);
            % ---------------------------------------------------------
            % Sleep onset and offset date and time
            res.clockSlpOnset{s, 1} = datestr(slpPeriods.onset, 'dd/mm/yyyy HH:MM');
            res.clockMidSleep{s, 1} = datestr(slpPeriods.onset+(slpPeriods.duration/2), 'dd/mm/yyyy HH:MM');
            res.clockFinAwake{s, 1} = datestr(slpPeriods.onset+slpPeriods.duration, 'dd/mm/yyyy HH:MM');
            % ---------------------------------------------------------
            % Sleep onset latency
            res.slpOnsetLat(s, 1) = (datenum(res.clockSlpOnset{s,1}, 'dd/mm/yyyy HH:MM') - datenum(res.clockEventOnset{s,1}, 'dd/mm/yyyy HH:MM')) *24*60;
            % ---------------------------------------------------------
            % Number and duration of awakenings
            waso = selectEventsUsingTime(ACT.analysis.events, events.onset(s), events.onset(s)+events.duration(s), ...
                'Label', 'waso', ...
                'Type', slpPeriodType);
            if isempty(waso) && strcmpi(eventType, 'sleepDiary')
                res.nAwakening(s, 1) = NaN;
                res.wakeAfterSlpOnset(s, 1) = NaN;
            else
                res.nAwakening(s, 1) = size(waso, 1);
                res.wakeAfterSlpOnset(s, 1) = sum(waso.duration) * 24*60;
            end
            res.awakePerHour(s, 1) = nan;
            % ---------------------------------------------------------
            % Snooze time
            res.snoozeTime(s, 1) = ((events.onset(s)+events.duration(s)) - (slpPeriods.onset+slpPeriods.duration)) * (24*60);
            % ---------------------------------------------------------
            % Total sleep time = (final awakening - sleep onset) - wake after sleep onset
            if isnan(res.nAwakening(s, 1))
                res.totSlpTime(s, 1) = (datenum(res.clockFinAwake{s,1}, 'dd/mm/yyyy HH:MM') - datenum(res.clockSlpOnset{s,1}, 'dd/mm/yyyy HH:MM')) *24*60;
            else
                res.totSlpTime(s, 1) = (datenum(res.clockFinAwake{s,1}, 'dd/mm/yyyy HH:MM') - datenum(res.clockSlpOnset{s,1}, 'dd/mm/yyyy HH:MM')) *24*60 - res.wakeAfterSlpOnset(s,1);
            end
            % Time spend in sleep state, regardless of night time awakenings
            res.slpPeriod(s, 1) = slpPeriods.duration*24*60;
            % Time spend between eyes closed and eyes open
            res.slpWindow(s, 1) = events.duration(s)*24*60;
            % ---------------------------------------------------------
            % Sleep efficiency
            res.slpEffSlpTime(s, 1) = (res.totSlpTime(s,1) / res.slpWindow(s,1)) * 100;
            res.slpEffSlpPeriod(s, 1) = (res.slpPeriod(s,1) / res.slpWindow(s,1)) * 100;
            % ---------------------------------------------------------
            % Average and variability of other data
            datatypes = fieldnames(ACT.metric);
            for ti = 1:length(datatypes)
                fnames = fieldnames(ACT.metric.(datatypes{ti}));
                for fi = 1:length(fnames)
                    % ---------------------------------------------------------
                    % Extract this days data and insert NaNs for rejected segments
                    [mdata, mtimes] = selectDataUsingTime(...
                        ACT.metric.(datatypes{ti}).(fnames{fi}).Data, ...
                        ACT.metric.(datatypes{ti}).(fnames{fi}).Time, ...
                        events.onset(s), ...
                        events.onset(s)+events.duration(s));
                    if isempty(mdata)
                        mdata = nan;
                        mtimes = 0;
                    end
                    mdata(events2idx(ACT, mtimes, 'Label', 'reject')) = nan;
                    % ---------------------------------------------------------
                    % Calculate average
                    res.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi})])(s, 1) = mean(mdata, 'omitnan');
                    % ---------------------------------------------------------
                    % For light data, calculate the mean above 1 lux
                    if strcmpi(datatypes{ti}, 'light')
                        res.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'Gt1Lux'])(s, 1) = mean(mdata(mdata > 1), 'omitnan');
                    end
                    [...
                        res.(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(s, 1), ...
                        res.(['clockOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){s, 1}...
                        ] = getAvMetric(ACT, mdata, mtimes, ...
                        'getMinMax', 'min', ...
                        'window',    30);
                    [...
                        res.(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(s, 1), ...
                        res.(['clockOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){s, 1}...
                        ] = getAvMetric(ACT, mdata, mtimes, ...
                        'getMinMax', 'max', ...
                        'window',    30);
                end
            end
        end
        % ---------------------------------------------------------
        % Sleep fragmentation index as the number of awakenings per hour
        res.awakePerHour = res.nAwakening ./ (res.slpPeriod/60);
    end


    function res = parseWakeEvents(ACT, events)
        % ---------------------------------------------------------
        % Create a new table
        res = table();
        % ---------------------------------------------------------
        % Indicator what type of sleep this is, night or nap
        res.type = repmat({'wake'}, size(events, 1)+1, 1);
        % ---------------------------------------------------------
        % Counter for the number of nights
        res.count = (1:size(events, 1)+1)';
        % ---------------------------------------------------------
        % Indicator how the event was created, by algorithm or manual
        res.eventOrigin = [events.type; events.type(1)];
        % ---------------------------------------------------------
        % Indicator whether the sleep was a week or weekend night
        % Note, Fri-Sat and Sat-Sun are weekend nights, all other nights are weeknights
        res.dayEventOnset = repmat({''}, size(events, 1)+1, 1);
        res.dayEventOffset = repmat({''}, size(events, 1)+1, 1);
        % ---------------------------------------------------------
        % Eyes closed and open date and time
        res.clockEventOnset = repmat({''}, size(events, 1)+1, 1);
        res.clockEventOffset = repmat({''}, size(events, 1)+1, 1);
        % ---------------------------------------------------------
        % For each sleep window check the sleep period and waso events
        for s = 1:size(events,1)+1
            if s == 1
                onset = ACT.xmin;
                offset = events.onset(s);
            elseif s == size(events,1)+1
                onset = events.onset(s-1)+events.duration(s-1);
                offset = ACT.xmax;
            else
                onset = events.onset(s-1)+events.duration(s-1);
                offset = events.onset(s);
            end
            res.dayEventOnset{s, 1} = datestr(onset, 'ddd');
            res.dayEventOffset{s, 1} = datestr(offset, 'ddd');
            % ---------------------------------------------------------
            % Eyes closed and open date and time
            res.clockEventOnset{s, 1} = datestr(onset, 'dd/mm/yyyy HH:MM');
            res.clockEventOffset{s, 1} = datestr(offset, 'dd/mm/yyyy HH:MM');
            res.eventDuration(s, 1) = (offset-onset)*24*60;
            % ---------------------------------------------------------
            % Average and variability of other data
            datatypes = fieldnames(ACT.metric);
            for ti = 1:length(datatypes)
                fnames = fieldnames(ACT.metric.(datatypes{ti}));
                for fi = 1:length(fnames)
                    % ---------------------------------------------------------
                    % Extract this days data and insert NaNs for rejected segments
                    [mdata, mtimes] = selectDataUsingTime(...
                        ACT.metric.(datatypes{ti}).(fnames{fi}).Data, ...
                        ACT.metric.(datatypes{ti}).(fnames{fi}).Time, ...
                        onset, ...
                        offset);
                    if isempty(mdata)
                        mdata = nan;
                        mtimes = 0;
                    end
                    mdata(events2idx(ACT, mtimes, 'Label', 'reject')) = nan;
                    % ---------------------------------------------------------
                    % Calculate average
                    res.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi})])(s, 1) = mean(mdata, 'omitnan');
                    % ---------------------------------------------------------
                    % For light data, calculate the mean above 1 lux
                    if strcmpi(datatypes{ti}, 'light')
                        res.(['av', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'Gt1Lux'])(s, 1) = mean(mdata(mdata > 1), 'omitnan');
                    end
                    [...
                        res.(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(s, 1), ...
                        res.(['clockOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){s, 1}...
                        ] = getAvMetric(ACT, mdata, mtimes, ...
                        'getMinMax', 'min', ...
                        'window',    30);
                    [...
                        res.(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m'])(s, 1), ...
                        res.(['clockOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin30m']){s, 1}...
                        ] = getAvMetric(ACT, mdata, mtimes, ...
                        'getMinMax', 'max', ...
                        'window',    30);
                end
            end
        end
    end

end

