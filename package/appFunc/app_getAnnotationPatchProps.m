function [XData, YData, Color] = app_getAnnotationPatchProps(app, intensity, startDate, endDate)

% Pick your colors
Colors = [...
    app.MinimalActivityButton.BackgroundColor;  ... % 0   = low activity
    app.LightActivityButton.BackgroundColor;    ... % 1   = light activity
    app.ModerateActivityButton.BackgroundColor; ... % 2   = moderate activity
    app.VigorousActivityButton.BackgroundColor; ... % 3   = vigorous activity
    ];

% Get annotate data
[annotate, time] = selectDataUsingTime(app.ACT.analysis.annotate.acceleration.Data, app.ACT.analysis.annotate.acceleration.Time, startDate, endDate);

% set non-wear bouts to nan
annotate(events2idx(app.ACT, time, 'Label', 'reject')) = NaN;

% Get the onset and duration of each block of activity
[onset, duration] = getBouts(annotate == intensity);
onset = time(onset);
duration = (duration*app.ACT.epoch)/(24*60*60);

if strcmpi(app.ACT.display.acceleration.view, 'angle')
    add = 360;
else
    add = 0;
end
YLim = [app.ACT.display.acceleration.range(1) + add, app.ACT.display.acceleration.range(2) + add];

XData = startDate;
YData = YLim(1);
for oi = 1:length(onset)
    XData = [XData, onset(oi), onset(oi), onset(oi)+duration(oi), onset(oi)+duration(oi)];
    YData = [YData, YLim(1), YLim(2), YLim(2), YLim(1)];
end
XData = [XData, endDate];
YData = [YData, YLim(1)];

Color = Colors(intensity+1, :);
end
