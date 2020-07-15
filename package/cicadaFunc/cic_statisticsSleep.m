function ACT = cic_statisticsSleep(ACT, eventType)
% ---------------------------------------------------------
% Extract the relevant events
switch eventType
    case 'actigraphy'
        slpWindowType = ACT.analysis.settings.sleepWindowType;
        slpPeriodType = 'actigraphy';
    case 'sleepDiary'
        slpWindowType = 'sleepDiary';
        slpPeriodType = 'sleepDiary';
end
slpWindows = selectEventsUsingTime(ACT.events, ACT.xmin, ACT.xmax, ...
    'Label', 'sleepWindow', ...
    'Type', slpWindowType);
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
% ---------------------------------------------------------
% Create a new table
ACT.stats.sleep.(eventType) = table();
% ---------------------------------------------------------
% Counter for the number of nights
ACT.stats.sleep.(eventType).slpCount = (1:size(slpWindows,1))';
% ---------------------------------------------------------
% Indicator how the event was created, by algorithm or manual
ACT.stats.sleep.(eventType).eventOrigin = slpWindows.type;
% ---------------------------------------------------------
% Indicator whether the sleep was a week or weekend night
% Note, Fri-Sat and Sat-Sun are weekend nights, all other nights are weeknights
ACT.stats.sleep.(eventType).day = cellstr(datestr(slpWindows.onset + slpWindows.duration, 'ddd'));
% ---------------------------------------------------------
% Eyes closed and open date and time
ACT.stats.sleep.(eventType).clockLightsOut = cellstr(datestr(slpWindows.onset, 'dd/mm/yyyy HH:MM'));
ACT.stats.sleep.(eventType).clockLightsOn = cellstr(datestr(slpWindows.onset + slpWindows.duration, 'dd/mm/yyyy HH:MM'));
% ---------------------------------------------------------
% For each sleep window check the sleep period and waso events
for s = 1:size(slpWindows,1)
    % ---------------------------------------------------------
    % Select sleep period events for this night
    slpPeriod = selectEventsUsingTime(ACT.events, slpWindows.onset(s), slpWindows.onset(s)+slpWindows.duration(s), ...
        'Label', 'sleepPeriod', ...
        'Type', slpPeriodType);
    % ---------------------------------------------------------
    % If there is no sleep period then continue to the next sleep window
    if isempty(slpPeriod)
        ACT.stats.sleep.(eventType).clockSlpOnset{s, 1} = 'na';
        ACT.stats.sleep.(eventType).clockFinAwake{s, 1} = 'na';
        ACT.stats.sleep.(eventType).slpOnsetLat(s, 1) = NaN;
        ACT.stats.sleep.(eventType).nAwakening(s, 1) = NaN;
        ACT.stats.sleep.(eventType).wakeAfterSlpOnset(s, 1) = NaN;
        ACT.stats.sleep.(eventType).totSlpTime(s, 1) = NaN;
        ACT.stats.sleep.(eventType).slpPeriod(s, 1) = NaN;
        ACT.stats.sleep.(eventType).slpWindow(s, 1) = NaN;
        ACT.stats.sleep.(eventType).slpEffSlpTime(s, 1) = NaN;
        ACT.stats.sleep.(eventType).slpEffSlpPeriod(s, 1) = NaN;
        continue
    end
    % ---------------------------------------------------------
    % Sleep onset and offset date and time
    ACT.stats.sleep.(eventType).clockSlpOnset{s, 1} = datestr(slpPeriod.onset, 'dd/mm/yyyy HH:MM');
    ACT.stats.sleep.(eventType).clockFinAwake{s, 1} = datestr(slpPeriod.onset+slpPeriod.duration, 'dd/mm/yyyy HH:MM');
    % ---------------------------------------------------------
    % Sleep onset latency
    ACT.stats.sleep.(eventType).slpOnsetLat(s, 1) = (datenum(ACT.stats.sleep.(eventType).clockSlpOnset{s,1}, 'dd/mm/yyyy HH:MM') - datenum(ACT.stats.sleep.(eventType).clockLightsOut{s,1}, 'dd/mm/yyyy HH:MM')) *24*60;
    % ---------------------------------------------------------
    % Number and duration of awakenings
    waso = selectEventsUsingTime(ACT.events, slpWindows.onset(s), slpWindows.onset(s)+slpWindows.duration(s), ...
        'Label', 'waso', ...
        'Type', slpPeriodType);
    ACT.stats.sleep.(eventType).nAwakening(s, 1) = size(waso, 1);
    ACT.stats.sleep.(eventType).wakeAfterSlpOnset(s, 1) = sum(waso.duration) * 24*60;
    % ---------------------------------------------------------
    % Total sleep time = (final awakening - sleep onset) - wake after sleep onset
    ACT.stats.sleep.(eventType).totSlpTime(s, 1) = (datenum(ACT.stats.sleep.(eventType).clockFinAwake{s,1}, 'dd/mm/yyyy HH:MM') - datenum(ACT.stats.sleep.(eventType).clockSlpOnset{s,1}, 'dd/mm/yyyy HH:MM')) *24*60 - ACT.stats.sleep.(eventType).wakeAfterSlpOnset(s,1);
    % Time spend in sleep state, regardless of night time awakenings
    ACT.stats.sleep.(eventType).slpPeriod(s, 1) = slpPeriod.duration*24*60;
    % Time spend between eyes closed and eyes open
    ACT.stats.sleep.(eventType).slpWindow(s, 1) = slpWindows.duration(s)*24*60;
    % ---------------------------------------------------------
    % Sleep efficiency
    ACT.stats.sleep.(eventType).slpEffSlpTime(s, 1) = (ACT.stats.sleep.(eventType).totSlpTime(s,1) / ACT.stats.sleep.(eventType).slpWindow(s,1)) * 100;
    ACT.stats.sleep.(eventType).slpEffSlpPeriod(s, 1) = (ACT.stats.sleep.(eventType).slpPeriod(s,1) / ACT.stats.sleep.(eventType).slpWindow(s,1)) * 100;
end
% ---------------------------------------------------------
% Sleep fragmentation index as the number of awakenings per hour
ACT.stats.sleep.(eventType).awakePerHour = ACT.stats.sleep.(eventType).nAwakening ./ (ACT.stats.sleep.(eventType).slpPeriod/60);

end

