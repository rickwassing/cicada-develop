function ACT = cic_statisticsCustom(ACT, label)
% ---------------------------------------------------------
% Create a new table with the labels name
tableName = lower(matlab.lang.makeValidName(label));
ACT.stats.custom.(tableName) = table();
% ---------------------------------------------------------
% Extract all these custom events
events = selectEventsUsingTime(ACT.analysis.events, ACT.xmin, ACT.xmax, 'Label', label, 'Type', 'customEvent');
% ---------------------------------------------------------
% Onset and offset of the events
ACT.stats.custom.(tableName).onset = cellstr(datestr(events.onset, 'dd/mm/yyyy HH:MM'));
ACT.stats.custom.(tableName).offset = cellstr(datestr(events.onset+events.duration, 'dd/mm/yyyy HH:MM'));
% ---------------------------------------------------------
% For each event, calculate the average statistics
for ei = 1:size(events, 1)
    % ---------------------------------------------------------
    % Extract this events Euclidean Norm
    [euclNormMinOne, times] = selectDataUsingTime(ACT.metric.acceleration.euclNormMinOne.Data, ACT.metric.acceleration.euclNormMinOne.Time, events.onset(ei), events.onset(ei)+events.duration(ei));
    % insert NaNs for rejected segments
    euclNormMinOne(events2idx(ACT, times, 'Label', 'reject')) = nan;
    % ---------------------------------------------------------
    % How much time and activity was spend in moderate to vigorous activity
    if isfield(ACT.analysis.annotate, 'acceleration')
        annotate = selectDataUsingTime(ACT.analysis.annotate.acceleration.Data, ACT.analysis.annotate.acceleration.Time, events.onset(ei), events.onset(ei)+events.duration(ei));
        % insert NaNs for rejected segments
        annotate(events2idx(ACT, times, 'Label', 'reject')) = nan;
        ACT.stats.custom.(tableName).hoursModVigAct(ei, 1) = (sum(annotate >= 3) * ACT.epoch) / 3600;
        ACT.stats.custom.(tableName).avEuclNormModVigAct(ei, 1) = nanmean(euclNormMinOne(annotate >= 3));
    else
        ACT.stats.custom.(tableName).hoursModVigAct(ei, 1) = NaN;
        ACT.stats.custom.(tableName).avEuclNormModVigAct(ei, 1) = NaN;
    end
    % ---------------------------------------------------------
    % Calculate average Euclidean norm
    ACT.stats.custom.(tableName).avEuclNorm(ei, 1) = nanmean(euclNormMinOne);
    % ---------------------------------------------------------
    % Calculate the min, max and delay onset only if the window is larger than 5 minutes
    if events.duration(ei) >= 5/(60*24)
        [...
            ACT.stats.custom.(tableName).minEuclNormMovWin5m(ei, 1), ...
            ACT.stats.custom.(tableName).delayOnsetMinEuclNormMovWin5m{ei, 1}, ...
            euclNormMovWin5m ...
            ] = getAvMetric(ACT, euclNormMinOne, times-times(1), ...
            'getMinMax', 'min', ...
            'window',    5);
        [...
            ACT.stats.custom.(tableName).maxEuclNormMovWin5m(ei, 1), ...
            ACT.stats.custom.(tableName).delayOnsetMaxEuclNormMovWin5m{ei, 1}, ...
            ] = getAvMetric(ACT, euclNormMinOne, times-times(1), ...
            'getMinMax', 'max', ...
            'window',    5);
        ACT.analysis.custom.(tableName).euclNormMovWin5m{ei, :} = asrow(euclNormMovWin5m);
    else
        ACT.stats.custom.(tableName).minEuclNormMovWin5m(ei, 1) = NaN;
        ACT.stats.custom.(tableName).delayOnsetMinEuclNormMovWin5m{ei, 1} = 'na';
        ACT.stats.custom.(tableName).maxEuclNormMovWin5m(ei, 1) = NaN;
        ACT.stats.custom.(tableName).delayOnsetMaxEuclNormMovWin5m{ei, 1} = 'na';
        ACT.analysis.custom.(tableName).euclNormMovWin5m{ei, :} = NaN;
    end
    % ---------------------------------------------------------
    % Average and variability of other data
    datatypes = ACT.display.order;
    for ti = 1:length(datatypes)
        fnames = fieldnames(ACT.metric.(datatypes{ti}));
        for fi = 1:length(fnames)
            % ---------------------------------------------------------
            % Extract this days data and insert NaNs for rejected segments
            [data, times] = selectDataUsingTime(ACT.metric.(datatypes{ti}).(fnames{fi}).Data, ACT.metric.(datatypes{ti}).(fnames{fi}).Time, events.onset(ei), events.onset(ei)+events.duration(ei));
            if isempty(data)
                data = nan;
                times = 0;
            end
            data(events2idx(ACT, times, 'Label', 'reject')) = nan;
            % ---------------------------------------------------------
            % Calculate average
            ACT.stats.custom.(tableName).(['av', titleCase(datatypes{ti}), titleCase(fnames{fi})])(ei, 1) = nanmean(data);
            % ---------------------------------------------------------
            % Calculate the min, max and delay onset only if the window is larger than 5 minutes
            if events.duration(ei) >= 5/(60*24) && ~all(isnan(data))
                [...
                    ACT.stats.custom.(tableName).(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1), ...
                    ACT.stats.custom.(tableName).(['delayOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1}, ...
                    tmp ...
                    ] = getAvMetric(ACT, data, times-times(1), ...
                    'getMinMax', 'min', ...
                    'window',    30);
                [...
                    ACT.stats.custom.(tableName).(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1), ...
                    ACT.stats.custom.(tableName).(['delayOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1}, ...
                    ] = getAvMetric(ACT, data, times-times(1), ...
                    'getMinMax', 'max', ...
                    'window',    30);
                ACT.analysis.custom.(tableName).([lower(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, :} = asrow(tmp);
            else
                ACT.stats.custom.(tableName).(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1) = NaN;
                ACT.stats.custom.(tableName).(['delayOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1} = 'na';
                ACT.stats.custom.(tableName).(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1) = NaN;
                ACT.stats.custom.(tableName).(['delayOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1} = 'na';
                ACT.analysis.custom.(tableName).([lower(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, :} = NaN;
            end
        end
        % ---------------------------------------------------------
        % If annotation of this datatype is available, calculate the time spent in each annotation level
        if isfield(ACT.analysis.annotate, datatypes{ti})
            % Extract the names of the levels
            if ~isfield(ACT.analysis.settings, [lower(datatypes{ti}), 'Levels'])
                warning('Did not find the annotation levels for ''%s'' metrics\n> In cic_statistics (line 147)', datatypes{ti})
                continue
            end
            levelsStr = ACT.analysis.settings.([lower(datatypes{ti}), 'Levels']);
            levelsData = unique(ACT.analysis.annotate.(datatypes{ti}).Data);
            if length(levelsStr) ~= length(levelsData)
                warning('Number of annotation levels for ''%s'' metrics in data does not match with the user-defined levels\n> In cic_statistics (line 153)', datatypes{ti})
                continue
            end
            [annotate, times] = selectDataUsingTime(ACT.analysis.annotate.(datatypes{ti}).Data, ACT.analysis.annotate.(datatypes{ti}).Time, events.onset(ei), events.onset(ei)+events.duration(ei));
            % insert NaNs for rejected segments
            annotate(events2idx(ACT, times, 'Label', 'reject')) = nan;
            for li = 1:length(levelsData)
                ACT.stats.custom.(tableName).(['hours', titleCase(levelsStr{li}), titleCase(datatypes{ti})])(ei, 1) = (sum(annotate == levelsData(li)) * ACT.epoch) / 3600;
            end
        end
    end
end

end
