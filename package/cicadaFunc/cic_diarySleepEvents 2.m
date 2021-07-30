function ACT = cic_diarySleepEvents(ACT)
% ---------------------------------------------------------
% First of all, delete any existing sleep diary events
ACT = cic_editEvents(ACT, 'delete', [], [], 'Label', 'sleepWindow', 'Type', 'sleepDiary');
ACT = cic_editEvents(ACT, 'delete', [], [], 'Label', 'sleepPeriod', 'Type', 'sleepDiary');
ACT = cic_editEvents(ACT, 'delete', [], [], 'Label', 'waso', 'Type', 'sleepDiary');
% ---------------------------------------------------------
% Add sleep windows, the period between lights out and on
sleepWindow.onset = datenum(ACT.analysis.sleepDiary.lightsOut, 'dd/mm/yyyy HH:MM');
sleepWindow.duration = datenum(ACT.analysis.sleepDiary.lightsOn, 'dd/mm/yyyy HH:MM') - sleepWindow.onset;
outOfBounds = sleepWindow.onset < ACT.xmin | sleepWindow.onset+sleepWindow.duration > ACT.xmax;
if all(outOfBounds)
    return
end
% ---------------------------------------------------------
% add the events
ACT = cic_editEvents(ACT, 'add', sleepWindow.onset, sleepWindow.duration, 'Label', 'sleepWindow', 'Type', 'sleepDiary');
% ---------------------------------------------------------
% Set the sleep window type to sleep diary
ACT.analysis.settings.sleepWindowType = 'sleepDiary';
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Insert sleep events from diary to ''ACT.analysis.events''');
ACT.history = char(ACT.history, 'ACT = cic_diarySleepEvents(ACT);');
% ---------------------------------------------------------
% We'll continue adding more sleep events if they exist, or return otherwise
% ---------------------------------------------------------
% Add sleep period, the period between sleep onset and final awakening
idx = ~ismissing(ACT.analysis.sleepDiary.sleepLatency) & ~ismissing(ACT.analysis.sleepDiary.finAwake);
if ~any(idx)
    return % If there is no data at all, then return
end
sleepPeriod.onset = datenum(ACT.analysis.sleepDiary.lightsOut(idx), 'dd/mm/yyyy HH:MM') + ACT.analysis.sleepDiary.sleepLatency(idx) / (24*60);
sleepPeriod.duration = datenum(ACT.analysis.sleepDiary.finAwake(idx), 'dd/mm/yyyy HH:MM') - sleepPeriod.onset;
% Add the events
ACT = cic_editEvents(ACT, 'add', sleepPeriod.onset, sleepPeriod.duration, 'Label', 'sleepPeriod', 'Type', 'sleepDiary');
% ---------------------------------------------------------
% Add wake after sleep onset events
idx = ~ismissing(ACT.analysis.sleepDiary.sleepLatency) & ~ismissing(ACT.analysis.sleepDiary.finAwake) & ~ismissing(ACT.analysis.sleepDiary.awakenings) & ~ismissing(ACT.analysis.sleepDiary.waso);
if ~any(idx)
    return % If there is no data at all, then return
end
tmpDiary = ACT.analysis.sleepDiary;
tmpDiary(~idx, :) = [];
waso = struct(); cnt = 0;
for wi = 1:length(tmpDiary.awakenings)
    for bi = 1:tmpDiary.awakenings(wi)
        cnt = cnt+1;
        slpPerOnset = datenum(tmpDiary.lightsOut(wi), 'dd/mm/yyyy HH:MM');
        slpPerDur = datenum(tmpDiary.lightsOn(wi), 'dd/mm/yyyy HH:MM') - datenum(tmpDiary.lightsOut(wi), 'dd/mm/yyyy HH:MM');
        waso.onset(cnt, 1) = slpPerOnset + bi * (slpPerDur/(tmpDiary.awakenings(wi)+1)) - tmpDiary.waso(wi) / (24*60*2);
        waso.duration(cnt, 1) = (tmpDiary.waso(wi) / tmpDiary.awakenings(wi)) / (24*60);
    end
end
% Add the events
ACT = cic_editEvents(ACT, 'add', waso.onset, waso.duration, 'Label', 'waso', 'Type', 'sleepDiary');
% Remove any out of bouds events
sleepDiaryEventIdx = strcmpi(ACT.analysis.events.type, 'sleepDiary');
outOfBounds = ACT.analysis.events.onset < ACT.xmin | ACT.analysis.events.onset+ACT.analysis.events.duration > ACT.xmax;
ACT.analysis.events(sleepDiaryEventIdx & outOfBounds, :) = [];
end