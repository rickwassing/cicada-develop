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

ACT.stats.sleep.(eventType) = parseSleepEvents(ACT, slpWindows, eventType, 'night', 'sleepPeriod', slpPeriodType);
if doNapWindows && ~isempty(napWindows)
    napStats = parseSleepEvents(ACT, napWindows, eventType, 'nap', 'napPeriod', slpPeriodType);
    ACT.stats.sleep.(eventType) = [ACT.stats.sleep.(eventType); napStats];
    [~, idx] = sort(datenum(ACT.stats.sleep.(eventType).clockLightsOut, 'dd/mm/yyyy HH:MM'));
    ACT.stats.sleep.(eventType) = ACT.stats.sleep.(eventType)(idx, :);
end

    function res = parseSleepEvents(ACT, events, eventType, sleepType, slpPeriodLabel, slpPeriodType)
        % ---------------------------------------------------------
        % Create a new table
        res = table();
        % ---------------------------------------------------------
        % Indicator what type of sleep this is, night or nap
        res.slpType = repmat({sleepType}, size(events,1), 1);
        % ---------------------------------------------------------
        % Counter for the number of nights
        res.slpCount = (1:size(events, 1))';
        % ---------------------------------------------------------
        % Indicator how the event was created, by algorithm or manual
        res.eventOrigin = events.type;
        % ---------------------------------------------------------
        % Indicator whether the sleep was a week or weekend night
        % Note, Fri-Sat and Sat-Sun are weekend nights, all other nights are weeknights
        res.dayLightsOn = cellstr(datestr(events.onset + events.duration, 'ddd'));
        % ---------------------------------------------------------
        % Eyes closed and open date and time
        res.clockLightsOut = cellstr(datestr(events.onset, 'dd/mm/yyyy HH:MM'));
        res.clockLightsOn = cellstr(datestr(events.onset + events.duration, 'dd/mm/yyyy HH:MM'));
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
                res.clockFinAwake{s, 1} = 'na';
                res.slpOnsetLat(s, 1) = NaN;
                res.nAwakening(s, 1) = NaN;
                res.wakeAfterSlpOnset(s, 1) = NaN;
                res.totSlpTime(s, 1) = NaN;
                res.slpPeriod(s, 1) = NaN;
                res.slpWindow(s, 1) = NaN;
                res.slpEffSlpTime(s, 1) = NaN;
                res.slpEffSlpPeriod(s, 1) = NaN;
                continue
            end
            % ---------------------------------------------------------
            % Sleep onset and offset date and time
            res.clockSlpOnset{s, 1} = datestr(slpPeriods.onset, 'dd/mm/yyyy HH:MM');
            res.clockFinAwake{s, 1} = datestr(slpPeriods.onset+slpPeriods.duration, 'dd/mm/yyyy HH:MM');
            % ---------------------------------------------------------
            % Sleep onset latency
            res.slpOnsetLat(s, 1) = (datenum(res.clockSlpOnset{s,1}, 'dd/mm/yyyy HH:MM') - datenum(res.clockLightsOut{s,1}, 'dd/mm/yyyy HH:MM')) *24*60;
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
            % ---------------------------------------------------------
            % Total sleep time = (final awakening - sleep onset) - wake after sleep onset
            res.totSlpTime(s, 1) = (datenum(res.clockFinAwake{s,1}, 'dd/mm/yyyy HH:MM') - datenum(res.clockSlpOnset{s,1}, 'dd/mm/yyyy HH:MM')) *24*60 - res.wakeAfterSlpOnset(s,1);
            % Time spend in sleep state, regardless of night time awakenings
            res.slpPeriod(s, 1) = slpPeriods.duration*24*60;
            % Time spend between eyes closed and eyes open
            res.slpWindow(s, 1) = events.duration(s)*24*60;
            % ---------------------------------------------------------
            % Sleep efficiency
            res.slpEffSlpTime(s, 1) = (res.totSlpTime(s,1) / res.slpWindow(s,1)) * 100;
            res.slpEffSlpPeriod(s, 1) = (res.slpPeriod(s,1) / res.slpWindow(s,1)) * 100;
        end
        % ---------------------------------------------------------
        % Sleep fragmentation index as the number of awakenings per hour
        res.awakePerHour = res.nAwakening ./ (res.slpPeriod/60);
        
    end

end

