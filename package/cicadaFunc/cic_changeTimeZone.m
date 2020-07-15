function ACT = cic_changeTimeZone(ACT, newTimeZone)
% ---------------------------------------------------------
% Change the main times vector
t = datetime(ACT.times, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
t.TimeZone = newTimeZone;
ACT.times = datenum(t);
ACT.xmin = ACT.times(1);
ACT.xmax = ACT.times(end);
% ---------------------------------------------------------
% Change the time in annotation data
t = datetime(ACT.analysis.annotate.Time, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
t.TimeZone = newTimeZone;
ACT.analysis.annotate.Time = datenum(t);
% ---------------------------------------------------------
% Change the time in all metrics
% Cut the metrics
metrictypes = fieldnames(ACT.metric);
for m = 1:length(metrictypes)
    if isstruct(ACT.metric.(metrictypes{m}))
        fnames = fieldnames(ACT.metric.(metrictypes{m}));
        for f = 1:length(fnames)
            t = datetime(ACT.metric.(metrictypes{m}).(fnames{f}).Time, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
            t.TimeZone = newTimeZone;
            ACT.metric.(metrictypes{m}).(fnames{f}).Time = datenum(t);
        end
    else
        t = datetime(ACT.metric.(metrictypes{m}).Time, 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
        t.TimeZone = newTimeZone;
        ACT.metric.(metrictypes{m}).Time = datenum(t);
    end
end
% ---------------------------------------------------------
% Change the time in all events
for ev = 1:size(ACT.events, 1)
    t = datetime(ACT.events.onset(ev), 'ConvertFrom', 'datenum', 'TimeZone', ACT.timezone);
    t.TimeZone = newTimeZone;
    ACT.events.onset(ev) = datenum(t);
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
