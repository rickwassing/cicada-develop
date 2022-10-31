function ACT = cic_ggirSleepWindowDetection(ACT)

% --------------------------------------------------------------------
%  PART 1 - INITIALIZE
% --------------------------------------------------------------------
enmo  = ACT.metric.acceleration.euclNormMinOne.Data;
angle = ACT.metric.acceleration.angle_z.Data;
time  = ACT.metric.acceleration.angle_z.Time;
% ---------------------------------------------------------
% If there is less then 1/5th of a day, then this algorithm won't work
if (ACT.xmax - ACT.xmin) <= 0.2
    return
end
% ---------------------------------------------------------
% Insert NaN's for all non-wear periods
idxReject = events2idx(ACT, time, 'Label', 'reject');
angle(idxReject) = nan;

% --------------------------------------------------------------------
% PART 2 - FIND SLEEP WINDOWS
% --------------------------------------------------------------------
onset    = nan(ACT.ndays,1);
duration = nan(ACT.ndays,1);

for d = 1:ACT.ndays
    % ---------------------------------------------------------
    % (1) Find the index of this days start and end times
    if d == 1 % if this is the first day, then use the first 24 hours as set by the user's actogram window, e.g. 15:00 - 15:00
        idxStartDate = find(time >= ACT.startdate+(d-1), 1, 'first');
        idxEndDate   = find(time < ACT.enddate-(ACT.ndays-d), 1, 'last');
        winSize      = idxEndDate - idxStartDate;
    else
        if isnan(onset(d-1)) % if the previous day did not have a sleep period, use this day's 24 hour period starting at the actogram window, e.g. 15:00
            idxStartDate = find(time >= ACT.startdate+(d-1), 1, 'first');
            idxEndDate   = find(time < ACT.enddate-(ACT.ndays-d), 1, 'last');
            winSize      = idxEndDate - idxStartDate;
        else % if the previous day had a sleep period, take the next 32 hours following the offset of the sleep period
            idxStartDate = find(time >= onset(d-1) + duration(d-1), 1, 'first');
            idxEndDate   = find(time < onset(d-1) + duration(d-1) + 32/24, 1, 'last');
            winSize      = idxEndDate - idxStartDate;
            if winSize < (3*3600/ACT.epoch) % We have reached the end if there is less than 3 hours of recording left
                break
            end
        end
    end
    % - check this interval does not start or end with NaN's
    if isnan(angle(idxStartDate))
        idxValidDate = find(~isnan(angle(idxStartDate:idxEndDate)), 1, 'first');
        if isempty(idxValidDate) % there is no non-NaN value
            continue
        end
        idxStartDate = idxStartDate + idxValidDate - 1;
    end
    if isnan(angle(idxEndDate))
        idxValidDate = find(~isnan(angle(idxStartDate:idxEndDate)), 1, 'last');
        idxEndDate = idxStartDate + idxValidDate - 1;
    end
    % Make sure we have enough data
    winSize = idxEndDate - idxStartDate;
    if winSize < (3*3600/ACT.epoch)
        continue
    end
    % ---------------------------------------------------------
    % (2) Determine the sleep onset and final awakening times
    [idxSleepWinOnset, idxSleepWinOffset] = ggirSleepWindowDetection(angle(idxStartDate:idxEndDate), ACT.epoch);
    % - If no sleep period was found in this day, continue to next day
    if isempty(idxSleepWinOnset) && isempty(idxSleepWinOffset); continue; end
    % ---------------------------------------------------------
    % (3) If the onset or offset marker is within 60 minutes of the edges
    % of this window, the actual sleep period may overlap with two
    % successive windows, so try again with an adjusted window +/- 1 hours
    % The while-loop is terminated after 10 iterations, or if the window
    % boundaries are near the edges of the data.
    onsetCloseToBoundary = idxSleepWinOnset <= (3600/ACT.epoch);
    offsetCloseToBoundary = idxSleepWinOffset >= winSize - (3600/ACT.epoch);
    iterCount = 0;
    while (onsetCloseToBoundary || offsetCloseToBoundary) && iterCount < 10
        % Enlarge the window size with one hour (3600/epoch length in seconds)
        if onsetCloseToBoundary && offsetCloseToBoundary
            idxStartDate = idxStartDate - 3600/ACT.epoch; if idxStartDate < 1; idxStartDate = 1; iterCount = 10; end
            idxEndDate   = idxEndDate   + 3600/ACT.epoch; if idxEndDate > length(angle); idxEndDate = length(angle); iterCount = 10; end
        elseif onsetCloseToBoundary
            idxStartDate = idxStartDate - 3600/ACT.epoch; if idxStartDate < 1; idxStartDate = 1; iterCount = 10; end
        elseif offsetCloseToBoundary
            idxEndDate   = idxEndDate   + 3600/ACT.epoch; if idxEndDate > length(angle); idxEndDate = length(angle); iterCount = 10; end
        end
        if isnan(angle(idxStartDate))
            idxValidDate = find(~isnan(angle(idxStartDate:idxEndDate)), 1, 'first');
            idxStartDate = idxStartDate + idxValidDate - 1;
        end
        if isnan(angle(idxEndDate))
            idxValidDate = find(~isnan(angle(idxStartDate:idxEndDate)), 1, 'last');
            idxEndDate = idxStartDate + idxValidDate - 1;
        end
        % Update the window size
        winSize = idxEndDate - idxStartDate;
        % Recalculate the sleep period 
        [idxSleepWinOnset, idxSleepWinOffset] = ggirSleepWindowDetection(angle(idxStartDate:idxEndDate), ACT.epoch);
        % Update the logical variables
        onsetCloseToBoundary = idxSleepWinOnset <= (3600/ACT.epoch);
        offsetCloseToBoundary = idxSleepWinOffset >= winSize - (3600/ACT.epoch);
        % Up the iteration count
        iterCount = iterCount+1;
    end
    % ---------------------------------------------------------
    % (4) Store the bed times
    tmpTime = time(idxStartDate:idxEndDate);
    onset(d,1) = tmpTime(idxSleepWinOnset);
    duration(d,1) = tmpTime(idxSleepWinOffset) - tmpTime(idxSleepWinOnset);
end
% ---------------------------------------------------------
% Remove any days where no in bed periods have been detected
rmIdx = isnan(onset);
onset(rmIdx)     = [];
duration(rmIdx) = [];
% ---------------------------------------------------------
% Remove any sleep windows that start or end within 60 minutes of the start
% or end of the recording
rmIdx = (onset - ACT.xmin) < 1/24;
onset(rmIdx)     = [];
duration(rmIdx) = [];
rmIdx = (ACT.xmax - (onset+duration)) < 1/24;
onset(rmIdx)     = [];
duration(rmIdx) = [];
% ---------------------------------------------------------
% Save new events to events table
% Note that the detected sleep period is actually used to demarcate the sleep window
if ~isempty(onset)
    ACT = cic_editEvents(ACT, 'delete', [], [], 'Label', 'sleepWindow', 'type', 'GGIR');
    ACT = cic_editEvents(ACT, 'add', onset, duration, 'label', 'sleepWindow', 'type', 'GGIR');
    ACT.analysis.settings.sleepWindowType = 'GGIR';
end
% ---------------------------------------------------------
% Set the sleep window type
ACT.analysis.settings.sleepWindowType = 'GGIR';
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'analysis');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% GGIR''s sleep detection algorithm (DOI: 10.1038/s41598-018-31266-z)');
ACT.history = char(ACT.history, 'ACT = cic_ggirSleepWindowDetection(ACT);');

end % EOF
