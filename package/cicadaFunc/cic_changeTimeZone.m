function ACT = cic_changeTimeZone(ACT, newTimeZone)
% ---------------------------------------------------------
% Change the main times vector
t = datetime(ACT.times, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
t.TimeZone = newTimeZone;
ACT.times = datenum(t);
ACT.xmin = ACT.times(1);
ACT.xmax = ACT.times(end);
% ---------------------------------------------------------
% Change the time in all metrics
% Cut the metrics
metrictypes = fieldnames(ACT.metric);
for mi = 1:length(metrictypes)
    if isstruct(ACT.metric.(metrictypes{mi}))
        fnames = fieldnames(ACT.metric.(metrictypes{mi}));
        for fi = 1:length(fnames)
            t = datetime(ACT.metric.(metrictypes{mi}).(fnames{fi}).Time, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
            t.TimeZone = newTimeZone;
            ACT.metric.(metrictypes{mi}).(fnames{fi}).Time = datenum(t);
        end
    else
        t = datetime(ACT.metric.(metrictypes{mi}).Time, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
        t.TimeZone = newTimeZone;
        ACT.metric.(metrictypes{mi}).Time = datenum(t);
    end
end
% ---------------------------------------------------------
% Change the time in annotation data
anottypes = fieldnames(ACT.analysis.annotate);
for ai = 1:length(anottypes)
    t = datetime(ACT.analysis.annotate.(anottypes{ai}).Time, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
    t.TimeZone = newTimeZone;
    ACT.analysis.annotate.(anottypes{ai}).Time = datenum(t);
end
% ---------------------------------------------------------
% Change the time in all events
for ev = 1:size(ACT.analysis.events, 1)
    t = datetime(ACT.analysis.events.onset(ev), 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
    t.TimeZone = newTimeZone;
    ACT.analysis.events.onset(ev) = datenum(t);
end
% ---------------------------------------------------------
% Save the new timezone to struct
ACT.timezone = newTimeZone;
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Change the time zone');
ACT.history = char(ACT.history, sprintf('ACT = cic_changeTimeZone(ACT, ''%s''); %% new time zone', newTimeZone));

end % EOF
