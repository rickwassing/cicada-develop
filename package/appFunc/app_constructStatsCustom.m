function app_constructStatsCustom(app, Title)

% ---------------------------------------------------------
% Return if the custom stats have been removed
if ~isfield(app.ACT.stats, 'custom')
    return
end

% Construct the Tab
Tab = app_constructTab(app, ['Tab_Custom-', Title], Title);
tableName = lower(matlab.lang.makeValidName(Title));
GridLayoutContainer = findobj(Tab.Children, 'Tag', 'TabGridLayoutContainerPanel');

% -----
% Update the Row Height of the grid layout if we can plot the average datatraces
if ~all(cellfun(@(t) all(isnan(t.Data)), app.ACT.analysis.custom.(tableName).euclNormMovWin5m))
    GridLayoutContainer.RowHeight = {150, '1x'};
    doPlotTimeseries = true;
else
    GridLayoutContainer.RowHeight = {1, '1x'};
    doPlotTimeseries = false;
end

% ---------------------------------------------------------
% Plot average patches
% ---------------------------------------------------------
if doPlotTimeseries
    % ---------------------------------------------------------
    % Euclidean Norm
    % ---------------------------------------------------------
    % Panel
    % -----
    % Check if component should mount
    if shouldComponentMount(app, GridLayoutContainer, ['CustomStats_AverageAccelerationPanel-', Title])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = 1;
        Layout.Column = [1, 4];
        % Define the properties
        props = {...
            'Tag', ['CustomStats_AverageAccelerationPanel-', Title]; ...
            'Title', 'Average Acceleration - 5m mov win'; ...
            'FontSize', 10; ...
            'FontWeight', 'bold'; ...
            'BackgroundColor', [1, 1, 1]; ...
            'Layout', Layout; ...
            };
        % Mount component using the 'mount_uipanel' function
        mountComponent(app, 'mount_uipanel', GridLayoutContainer, props);
    end
    % -----
    % Extract parent panel object to use for its children
    parent = findobj(GridLayoutContainer.Children, 'Tag', ['CustomStats_AverageAccelerationPanel-', Title]);
    % -----
    % GridLayout
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['CustomStats_AverageAccelerationGridlayout-', Title])
        % Define the properties
        props = {...
            'Tag', ['CustomStats_AverageAccelerationGridlayout-', Title]; ...
            'ColumnWidth', {'1x'}; ...
            'RowHeight', {'1x'}; ...
            'Padding', [3, 3, 3, 3]; ...
            };
        % Mount component using the 'mount_uigridlayout' function
        mountComponent(app, 'mount_uigridlayout', parent, props);
    end
    % -----
    % Extract parent panel object to use for its children
    parent = findobj(parent.Children, 'Tag', ['CustomStats_AverageAccelerationGridlayout-', Title]);
    % -----
    % Patch, Text and Markers
    % -----
    pnts = min(cellfun(@(t) t.length, app.ACT.analysis.custom.(tableName).euclNormMovWin5m));
    data = mean(cell2mat(cellfun(@(t) asrow(t.Data(1:pnts)), app.ACT.analysis.custom.(tableName).euclNormMovWin5m, 'UniformOutput', false)), 'omitnan');
    times = ((0:pnts-1).*app.ACT.epoch/(60*60*24))';
    [~, idxMin] = min(data);
    [~, idxMax] = max(data);
    app_constructStatsAverageDayGraph(app, parent, timeseries(ascolumn(data), times), ...
        'euclNormMovWin5m', 'mg', 1000, ...
        datestr(times(idxMax), 'HH:MM'), ...
        datestr(times(idxMin), 'HH:MM'), ...
        max(data), ...
        min(data));
    % ---------------------------------------------------------
    % Light
    % ---------------------------------------------------------
    % Check if this datatype exists, and select the first Light Metric
    % -----
    if ismember('light', fieldnames(app.ACT.metric))
        fnames = fieldnames(app.ACT.metric.light);
        fname = titleCase(fnames{1});
        % -----
        % Panel
        % -----
        % Check if component should mount
        if shouldComponentMount(app, GridLayoutContainer, ['CustomStats_AverageLightPanel-', Title])
            % Set Layout
            Layout = app.DataPanel.Layout;
            Layout.Row = 1;
            Layout.Column = [5, 8];
            % Define the properties
            props = {...
                'Tag', ['CustomStats_AverageLightPanel-', Title]; ...
                'Title', 'Average Light - 5m mov win'; ...
                'FontSize', 10; ...
                'FontWeight', 'bold'; ...
                'BackgroundColor', [1, 1, 1]; ...
                'Layout', Layout; ...
                };
            % Mount component using the 'mount_uipanel' function
            mountComponent(app, 'mount_uipanel', GridLayoutContainer, props);
        end
        % -----
        % Extract parent panel object to use for its children
        parent = findobj(GridLayoutContainer.Children, 'Tag', ['CustomStats_AverageLightPanel-', Title]);
        % -----
        % GridLayout
        % -----
        % Check if component should mount
        if shouldComponentMount(app, parent, ['CustomStats_AverageLightGridlayout-', Title])
            % Define the properties
            props = {...
                'Tag', ['CustomStats_AverageLightGridlayout-', Title]; ...
                'ColumnWidth', {'1x'}; ...
                'RowHeight', {'1x'}; ...
                'Padding', [3, 3, 3, 3]; ...
                };
            % Mount component using the 'mount_uigridlayout' function
            mountComponent(app, 'mount_uigridlayout', parent, props);
        end
        % -----
        % Extract parent panel object to use for its children
        parent = findobj(parent.Children, 'Tag', ['CustomStats_AverageLightGridlayout-', Title]);
        % -----
        % Patch, Text and Markers
        % -----
        pnts = min(cellfun(@(t) t.length, app.ACT.analysis.custom.(tableName).(['light', fname, 'MovWin5m'])));
        data = mean(cell2mat(cellfun(@(t) asrow(t.Data(1:pnts)), app.ACT.analysis.custom.(tableName).(['light', fname, 'MovWin5m']), 'UniformOutput', false)), 'omitnan');
        times = ((0:pnts-1).*app.ACT.epoch/(60*60*24))';
        [~, idxMin] = min(data);
        [~, idxMax] = max(data);
        app_constructStatsAverageDayGraph(app, parent, timeseries(ascolumn(data), times), ...
            ['light', fname, 'MovWin5m'], 'lux', 1, ...
            datestr(times(idxMax), 'HH:MM'), ...
            datestr(times(idxMin), 'HH:MM'), ...
            max(data), ...
            min(data));
    end
    % ---------------------------------------------------------
    % Temperature
    % ---------------------------------------------------------
    % Check if this datatype exists, and select the first Light Metric
    % -----
    if ismember('temperature', fieldnames(app.ACT.metric))
        fnames = fieldnames(app.ACT.metric.temperature);
        fname = titleCase(fnames{1});
        % -----
        % Panel
        % -----
        % Check if component should mount
        if shouldComponentMount(app, GridLayoutContainer, ['CustomStats_AverageTemperaturePanel-', Title])
            % Set Layout
            Layout = app.DataPanel.Layout;
            Layout.Row = 1;
            Layout.Column = [9, 12];
            % Define the properties
            props = {...
                'Tag', ['CustomStats_AverageTemperaturePanel-', Title]; ...
                'Title', 'Average Temperature - 5m mov win'; ...
                'FontSize', 10; ...
                'FontWeight', 'bold'; ...
                'BackgroundColor', [1, 1, 1]; ...
                'Layout', Layout; ...
                };
            % Mount component using the 'mount_uipanel' function
            mountComponent(app, 'mount_uipanel', GridLayoutContainer, props);
        end
        % -----
        % Extract parent panel object to use for its children
        parent = findobj(GridLayoutContainer.Children, 'Tag', ['CustomStats_AverageTemperaturePanel-', Title]);
        % -----
        % GridLayout
        % -----
        % Check if component should mount
        if shouldComponentMount(app, parent, ['CustomStats_AverageTemperatureGridlayout-', Title])
            % Define the properties
            props = {...
                'Tag', ['CustomStats_AverageTemperatureGridlayout-', Title]; ...
                'ColumnWidth', {'1x'}; ...
                'RowHeight', {'1x'}; ...
                'Padding', [3, 3, 3, 3]; ...
                };
            % Mount component using the 'mount_uigridlayout' function
            mountComponent(app, 'mount_uigridlayout', parent, props);
        end
        % -----
        % Extract parent panel object to use for its children
        parent = findobj(parent.Children, 'Tag', ['CustomStats_AverageTemperatureGridlayout-', Title]);
        % -----
        % Patch, Text and Markers
        % -----
        pnts = min(cellfun(@(t) t.length, app.ACT.analysis.custom.(tableName).(['temperature', fname, 'MovWin5m'])));
        data = mean(cell2mat(cellfun(@(t) asrow(t.Data(1:pnts)), app.ACT.analysis.custom.(tableName).(['temperature', fname, 'MovWin5m']), 'UniformOutput', false)), 'omitnan');
        times = ((0:pnts-1).*app.ACT.epoch/(60*60*24))';
        [~, idxMin] = min(data);
        [~, idxMax] = max(data);
        app_constructStatsAverageDayGraph(app, parent, timeseries(ascolumn(data), times), ...
            ['temperature', fname, 'MovWin5m'], '*C', 1, ...
            datestr(times(idxMax), 'HH:MM'), ...
            datestr(times(idxMin), 'HH:MM'), ...
            max(data), ...
            min(data));
    end
end
% ---------------------------------------------------------
% Table 
% ---------------------------------------------------------
% Panel
% -----
% Check if component should mount
if shouldComponentMount(app, GridLayoutContainer, ['CustomStats_Panel-', Title])
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 2;
    Layout.Column = [1, 12];
    % Define the properties
    props = {...
        'Tag', ['CustomStats_Panel-', Title]; ...
        'Title', ''; ...
        'BackgroundColor', [1, 1, 1]; ...
        'Layout', Layout; ...
        };
    % Mount component using the 'mount_uipanel' function
    mountComponent(app, 'mount_uipanel', GridLayoutContainer, props);
end
% -----
% Extract parent panel object to use for its children
parent = findobj(GridLayoutContainer.Children, 'Tag', ['CustomStats_Panel-', Title]);
% -----
% GridLayout
% -----
% Check if component should mount
if shouldComponentMount(app, parent, ['CustomStats_Gridlayout-', Title])
    % Define the properties
    props = {...
        'Tag', ['CustomStats_Gridlayout-', Title]; ...
        'ColumnWidth', [{150}, repmat({65}, 1, size(app.ACT.stats.custom.(tableName), 1))]; ...
        'RowHeight', repmat({21}, 1, size(app.ACT.stats.custom.(tableName), 2)); ...
        'ColumnSpacing', 6; ...
        'RowSpacing', 0; ...
        'Padding', [0, 0, 0, 0]; ...
        'Scrollable', 'on'; ...
        };
    % Mount component using the 'mount_uigridlayout' function
    mountComponent(app, 'mount_uigridlayout', parent, props);
end
% -----
% Extract parent girdlayout object to use for its children
parent = findobj(parent.Children, 'Tag', ['CustomStats_Gridlayout-', Title]);
% Extract all the variable names from the daily analysis table
fnames = app.ACT.stats.custom.(tableName).Properties.VariableNames;
% -----
% For each fieldname ...
for fi = 1:length(fnames)
    % -----
    % For each event ...
    for ei = 1:size(app.ACT.stats.custom.(tableName), 1)
        % -----
        % ... mount/construct a label of the variable value
        % -----
        % Check if component should mount
        if shouldComponentMount(app, parent, ['CustomStats_Value-', fnames{fi}, '_event-', num2str(ei)])
            % Set Layout
            Layout = app.DataPanel.Layout;
            Layout.Row = fi;
            Layout.Column = ei+1;
            % Define the properties
            value = app.ACT.stats.custom.(tableName).(fnames{fi})(ei);
            % Format the Text
            switch fnames{fi}
                case 'onset'
                    Text = [value{:}(1:5), ' ', value{:}(12:end)];
                    Color = [0.13, 0.38, 0.19];
                    Label = 'Start date';
                case 'offset'
                    Text = [value{:}(1:5), ' ', value{:}(12:end)];
                    Color = [0.13, 0.38, 0.19];
                    Label = 'End date';
                case 'hoursModVigAct'
                    Text = ifelse(isnan(value), '-', duration2str(value/24));
                    Color = [0.49, 0.18, 0.56];
                    Label = 'Mod/vig activity time';
                case 'avEuclNormModVigAct'
                    Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
                    Color = [0.49, 0.18, 0.56];
                    Label = 'Mod/vig activity level';
                case 'avEuclNorm'
                    Text = sprintf('%.0f mg', value*1000);
                    Color = [0.49, 0.18, 0.56];
                    Label = 'Mean Eucl. norm';
                case 'minEuclNormMovWin5m'
                    Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
                    Color = [0.49, 0.18, 0.56];
                    Label = 'Min activity (5m mov win)';
                case 'delayOnsetMinEuclNormMovWin5m'
                    Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                    Color = [0.49, 0.18, 0.56];
                    Label = 'Delay onset min act';
                case 'maxEuclNormMovWin5m'
                    Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
                    Color = [0.49, 0.18, 0.56];
                    Label = 'Max activity (5m mov win)';
                case 'delayOnsetMaxEuclNormMovWin5m'
                    Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                    Color = [0.49, 0.18, 0.56];
                    Label = 'Delay onset max act';
                otherwise
                    if strRegexpCheck(fnames{fi}, 'hours')
                        Text = ifelse(value == 0, '-', duration2str(value/24));
                        Color = [0.15, 0.15, 0.15];
                        Label = fnames{fi};
                    elseif strRegexpCheck(fnames{fi}, 'min')
                        Text = ifelse(isnan(value), '-', sprintf('%.0f', value));
                        Color = [0.15, 0.15, 0.15];
                        Label = 'Min';
                    elseif strRegexpCheck(fnames{fi}, 'max')
                        Text = ifelse(isnan(value), '-', sprintf('%.0f', value));
                        Color = [0.15, 0.15, 0.15];
                        Label = 'Max';
                    elseif strRegexpCheck(fnames{fi}, 'delay')
                        Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                        Color = [0.15, 0.15, 0.15];
                        Label = 'Delay';
                    elseif isnumeric(value)
                        Text = ifelse(isnan(value), '-', sprintf('%.0f', value));
                        Color = [0.15, 0.15, 0.15];
                        Label = fnames{fi};
                    elseif iscell(value)
                        Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                        Color = [0.15, 0.15, 0.15];
                        Label = fnames{fi};
                    end
            end
            props = {...
                'Tag', ['CustomStats_Value-', fnames{fi}, '_event-', num2str(ei)]; ...
                'Text', Text; ...
                'FontColor', Color; ...
                'HorizontalAlignment', 'center'; ...
                'Layout', Layout; ...
                };
            % Mount component using the 'mount_uilabel' function
            mountComponent(app, 'mount_uilabel', parent, props);
        end
    end
    % -----
    % ... mount/construct a label
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['CustomStats_Label-', fnames{fi}])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = fi;
        Layout.Column = 1;
        % Set FontWeight
        if strRegexpCheck(Label, '^Min')
            FontWeight = 'normal';
        elseif strRegexpCheck(Label, '^Max')
            FontWeight = 'normal';
        elseif strRegexpCheck(Label, '^Delay')
            FontWeight = 'normal';
        else
            FontWeight = 'bold';
        end
        % Define the properties
        props = {...
            'Tag', ['CustomStats_Label-', fnames{fi}]; ...
            'Text', Label; ...
            'FontWeight', FontWeight; ...
            'HorizontalAlignment', 'right'; ...
            'Layout', Layout; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_uilabel', parent, props);
    end
end

end %EOF
