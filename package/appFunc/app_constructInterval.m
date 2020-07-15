function app_constructTab(app)
% ---------------------------------------------------------
% If the position field of the interval is not set, then there is no interval to plot, so return
if ~isfield(app.Interval, 'Position')
    return
end
% ---------------------------------------------------------
% Only go ahead if 'Interval' is listed in the component list
if ~ismember('Interval', app.ComponentList)
    return
end

% ---------------------------------------------------------
% We will plot the cursor in the axes of Events and Acceleration
axesTypes = [{'events'}; {'acceleration'}];
for ai = 1:length(axesTypes)
    % ---------------------------------------------------------
    % Extract the parents of this interval to know which days it comprises
    days = [];
    for pi = 1:length(app.Interval.Parents)
        days = [days; app.Interval.Parents(pi).UserData.Day];
    end
    days = days(1):days(end);
    % ---------------------------------------------------------
    % For each of the days ...
    for di = 1:length(days)
        % ---------------------------------------------------------
        % Check if component should mount, otherwise construct the component
        if shouldComponentMount(app, app.DataContainer, ['Interval_day-', num2str(days(di)), '_type-', axesTypes{ai}])
            % Find the parent axes
            ax = findobj(app.DataContainer.Children, 'Tag', ['Axis_day-' num2str(days(di)) '_type-' axesTypes{ai}]);
            % Define the properties
            XData = [app.Interval.Position(1), app.Interval.Position(1), app.Interval.Position(end), app.Interval.Position(end)];
            YData = app_getCursorYData(app, axesTypes{ai});
            props = { ...
                'Tag', ['Interval_day-', num2str(days(di)), '_type-', axesTypes{ai}]; ...
                'XData', ifelse(numel(app.Interval.Position) == 1, XData(1:2), XData); ...
                'YData', ifelse(numel(app.Interval.Position) == 1, YData, [YData, fliplr(YData)]); ...
                'EdgeColor', [0.1765, 0.3725, 0.6745]; ...
                'FaceColor', [0.1765, 0.3725, 0.6745]; ...
                'FaceAlpha', 0.3; ...
                'LineStyle', '-'; ...
                'LineWidth', 2; ...
                };
            % Mount component using the 'mount_patch' function
            mountComponent(app, 'mount_patch', ax, props);
        else
            % Construct the component with its updated XData and YData
            XData = [app.Interval.Position(1), app.Interval.Position(1), app.Interval.Position(end), app.Interval.Position(end)];
            YData = app_getCursorYData(app, axesTypes{ai});
            constructComponent(app, ['Interval_day-', num2str(days(di)), '_type-', axesTypes{ai}], app.DataContainer, { ...
                'XData', ifelse(numel(app.Interval.Position) == 1, XData(1:2), XData); ...
                'YData', ifelse(numel(app.Interval.Position) == 1, YData, [YData, fliplr(YData)]); ...
                });
        end
    end
end

end %EOF
