function ACT = cic_statistics(ACT, varargin)

if nargin == 1 % if analysis type is not specified, do all
    do = {'daily', 'sleep', 'average'};
elseif ismember('average', varargin) % to calculate averages, we first need to calculate sleep and daily
    do = {'daily', 'sleep', 'average'};
else % otherwise do whatever the user specified
    do = varargin;
end

% ---------------------------------------------------------
% VARIABLES ABOUT EACH DAY
if ismember('daily', do)
    % Run stats
    ACT = cic_statisticsDaily(ACT);
end

% ---------------------------------------------------------
% VARIABLES ABOUT EACH SLEEP WINDOW
if ismember('sleep', do)
    if isfield(ACT.analysis.settings, 'sleepWindowType')
        % Run stats
        ACT = cic_statisticsSleep(ACT, 'actigraphy');
        ACT = cic_statisticsSleep(ACT, 'sleepDiary');
    end
end

% ---------------------------------------------------------
% AVERAGE VARIABLES
if ismember('average', do)
    % Run stats
    ACT = cic_statisticsAverage(ACT);
end


% ---------------------------------------------------------
% CUSTOM EVENT VARIABLES
if ismember('customEvent', do)
    % ---------------------------------------------------------
    % The label of the custom event is specified in the second variable input argument
    label = varargin{2};
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
        % Calculate the min, max and clock onset only if the window is larger than 5 minutes
        if events.duration(ei) >= 5/(60*24)
            [...
                ACT.stats.custom.(tableName).minEuclNormMovWin5m(ei, 1), ...
                ACT.stats.custom.(tableName).clockOnsetMinEuclNormMovWin5m{ei, 1}, ...
                euclNormMovWin5m ...
                ] = getAvMetric(ACT, euclNormMinOne, times, ...
                'getMinMax', 'min', ...
                'window',    5);
            [...
                ACT.stats.custom.(tableName).maxEuclNormMovWin5m(ei, 1), ...
                ACT.stats.custom.(tableName).clockOnsetMaxEuclNormMovWin5m{ei, 1}, ...
                ] = getAvMetric(ACT, euclNormMinOne, times, ...
                'getMinMax', 'max', ...
                'window',    5);
            ACT.analysis.custom.(tableName).euclNormMovWin5m{ei, :} = asrow(euclNormMovWin5m);
        else
            ACT.stats.custom.(tableName).minEuclNormMovWin5m(ei, 1) = NaN;
            ACT.stats.custom.(tableName).clockOnsetMinEuclNormMovWin5m{ei, 1} = 'na';
            ACT.stats.custom.(tableName).maxEuclNormMovWin5m(ei, 1) = NaN;
            ACT.stats.custom.(tableName).clockOnsetMaxEuclNormMovWin5m{ei, 1} = 'na';
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
                % Calculate the min, max and clock onset only if the window is larger than 5 minutes
                if events.duration(ei) >= 5/(60*24)
                    [...
                        ACT.stats.custom.(tableName).(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1), ...
                        ACT.stats.custom.(tableName).(['clockOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1}, ...
                        tmp ...
                        ] = getAvMetric(ACT, data, times, ...
                        'getMinMax', 'min', ...
                        'window',    30);
                    [...
                        ACT.stats.custom.(tableName).(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1), ...
                        ACT.stats.custom.(tableName).(['clockOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1}, ...
                        ] = getAvMetric(ACT, data, times, ...
                        'getMinMax', 'max', ...
                        'window',    30);
                    ACT.analysis.custom.(tableName).([lower(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, :} = asrow(tmp);
                else
                    ACT.stats.custom.(tableName).(['min', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1) = NaN;
                    ACT.stats.custom.(tableName).(['clockOnsetMin', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1} = 'na';
                    ACT.stats.custom.(tableName).(['max', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m'])(ei, 1) = NaN;
                    ACT.stats.custom.(tableName).(['clockOnsetMax', titleCase(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, 1} = 'na';
                    ACT.analysis.custom.(tableName).([lower(datatypes{ti}), titleCase(fnames{fi}), 'MovWin5m']){ei, :} = NaN;
                end
            end
        end
    end
end

% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'statistics');
% ---------------------------------------------------------
% Write history
if ismember('customEvent', do)
    ACT.history = char(ACT.history, '% -----');
    ACT.history = char(ACT.history, '% Generate statistics for custom events');
    ACT.history = char(ACT.history, sprintf('ACT = cic_statistics(ACT, ''customEvent'', ''%s'');', varargin{2}));
else
    ACT.history = char(ACT.history, '% ---------------------------------------------------------');
    ACT.history = char(ACT.history, '% Generate statistics');
    ACT.history = char(ACT.history, 'ACT = cic_statistics(ACT);');
end

end % EOF
