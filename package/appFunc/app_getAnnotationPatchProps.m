function [XData, YData, Color] = app_getAnnotationPatchProps(app, fname, intensity, nlevels, startDate, endDate)

% ---------------------------------------------------------
% Pick your colors
% -----
% load
cmap = load('colormap_davos.mat', 'davos');
cmap = cmap.davos;
% -----
% modify HSV space
cmap = rgb2hsv(cmap);
cmap(:, 1) = mod(cmap(:, 1)+0.375, 1);
cmap(:, 2) = cmap(:, 2).^1;
cmap(:, 3) = cmap(:, 3);
% -----
% modify in RGB space
cmap = flipud(hsv2rgb(cmap)).^0.5;
% -----
Colors = cmap(round(linspace(1, size(cmap, 1), max([nlevels+1, 4]))), :);
Colors(1, :) = [];

if strcmpi(fname, 'acceleration')
    app.MinimalActivityButton.BackgroundColor = Colors(1, :);
    app.LightActivityButton.BackgroundColor = Colors(2, :);
    app.ModerateActivityButton.BackgroundColor = Colors(3, :);
    app.VigorousActivityButton.BackgroundColor = Colors(4, :);
end

% Get annotate data
[annotate, time] = selectDataUsingTime(app.ACT.analysis.annotate.(fname).Data, app.ACT.analysis.annotate.(fname).Time, startDate, endDate);

% set non-wear bouts to nan
annotate(events2idx(app.ACT, time, 'Label', 'reject')) = NaN;

% Get the onset and duration of each block of activity
[onset, duration] = getBouts(annotate == intensity);
onset = time(onset);
duration = (duration*app.ACT.epoch)/(24*60*60);

if strcmpi(app.ACT.display.acceleration.view, 'angle') && strcmpi(fname, 'acceleration')
    add = 360;
else
    add = 0;
end
YLim = [app.ACT.display.(fname).range(1) + add, app.ACT.display.(fname).range(2) + add];

XData = startDate;
YData = YLim(1);
for oi = 1:length(onset)
    XData = [XData, onset(oi), onset(oi), onset(oi)+duration(oi), onset(oi)+duration(oi)];
    YData = [YData, YLim(1), YLim(2), YLim(2), YLim(1)];
end
XData = [XData, endDate];
YData = [YData, YLim(1)]+0.0001;

Color = Colors(intensity, :);

end
