function app_constructStatsDaily(app)

% ---------------------------------------------------------
% Enable/Disable the ReAnalyse buttons if required
if isempty(app.ACT.filename)
    app.DailyStats_RegenStatsButton.Enable = 'off';
    app.DailyStats_RegenStatsButton.Text = 'Generate Statistics';
    app.DailyStats_Container.Visible = 'off';
    return
elseif ~isfield(app.ACT.stats, 'average')
    app.DailyStats_RegenStatsButton.Enable = 'on';
    app.DailyStats_RegenStatsButton.Text = 'Generate Statistics';
    app.DailyStats_Container.Visible = 'off';
    return
else
    app.DailyStats_RegenStatsButton.Enable = 'off';
    app.DailyStats_RegenStatsButton.Text = 'Statistics Up-To-Date';
    app.DailyStats_Container.Visible = 'on';
end

% ---------------------------------------------------------
% Annotation colors
annotClrs = [...
    app.MinimalActivityButton.BackgroundColor;  ... % 0   = low activity
    app.LightActivityButton.BackgroundColor;    ... % 1   = light activity
    app.ModerateActivityButton.BackgroundColor; ... % 2   = moderate activity
    app.VigorousActivityButton.BackgroundColor; ... % 3   = vigorous activity
    ];
% ---------------------------------------------------------
% Daily overview
% ---------------------------------------------------------
% UIAxes
% -----
if shouldComponentMount(app, app.GridLayoutDailyStats_Container, 'DailyStats_UIAxesOverview')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = [2, 12];
    % Define the properties
    props = { ...
        'Tag', 'DailyStats_UIAxesOverview'; ...
        'XLim', [0.5, max([size(app.ACT.stats.daily, 1), 14])+0.5]; ...
        'XTick', 1:size(app.ACT.stats.daily, 1); ...
        'XTickLabel', cellfun(@(x) x(1:end-5), app.ACT.stats.daily.date, 'UniformOutput', false); ...
        'YDir', 'reverse'; ...
        'YLim', [0, 24]; ...
        'YTick', 0:2:24; ...
        'YTickLabel', datestr(0:2/24:1, 'HH:MM'); ...
        'BackgroundColor', [0.95, 0.95, 0.95]; ...
        'XColor', [0.30, 0.60, 0.46]; ...
        'YColor', [0.70, 0.33, 0.78]; ...
        'Layout', Layout; ...
        'Layer', 'top'; ...
        'FontSize', 10; ...
        'Box', 'on'; ...
        };
    % Mount component using the 'mount_uiaxes' function
    Component = mountComponent(app, 'mount_uiaxes', app.GridLayoutDailyStats_Container, props);
    Component.YLabel.String = '< pm - am >';
end
% -----
% Extract parent axes object to use for its children
parent = findobj(app.GridLayoutDailyStats_Container.Children, 'Tag', 'DailyStats_UIAxesOverview');
% -----
% Initialise TickMarks
TickMarkXData = [];
TickMarkYData = [];
% For each day ...
for di = 1:size(app.ACT.stats.daily, 1)
    % Get start and enddate for this day
    startDate = datenum(app.ACT.stats.daily.date{di}, 'dd/mm/yyyy');
    endDate = startDate+1-(app.ACT.epoch/(60*60*24));
    % -----
    % Patch Euclidean Norm
    % -----
    % Extract the Euclidean Norm
    [x, y] = selectDataUsingTime(app.ACT.metric.acceleration.bpFiltEuclNorm.Data, app.ACT.metric.acceleration.bpFiltEuclNorm.Time, startDate, endDate);
    % Construct X and Y data
    XData = [ones(size(x))*di-map(x, 0, app.ACT.display.acceleration.euclNorm.range(2), 0, 0.33, true); di; di];
    YData = mod([y; y(end); y(1)], 1)*24;
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['DailyStats_PatchOverviewEuclNorm_day-', num2str(di)])
        % Define the properties
        props = {...
            'Tag', ['DailyStats_PatchOverviewEuclNorm_day-', num2str(di)]; ...
            'XData', XData; ...
            'YData', YData; ...
            'CData', 0.33-([XData(2:end); XData(end)]-di); ...
            'FaceColor', 'interp'; ...
            'EdgeColor', 'interp'; ...
            'LineStyle', '-'; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_patch', parent, props);
    else
        % Construct the component with its updated X, Y and CData
        constructComponent(app, ['DailyStats_PatchOverviewEuclNorm_day-', num2str(di)], parent, {...
            'XData', XData; ...
            'YData', YData; ...
            'CData', 0.33-([XData(2:end); XData(end)]-di); ...
            });
    end
    % -----
    % Patches Annotation
    % -----
    % Only mount/construct annotation patches if there is any annotation
    if any(app.ACT.analysis.annotate.Data ~= 0)
        % -----
        % Extract the annotation data
        [x, y] = selectDataUsingTime(app.ACT.analysis.annotate.Data, app.ACT.analysis.annotate.Time, startDate, endDate);
        % set non-wear bouts to nan
        x(events2idx(app.ACT, y, 'Label', 'reject')) = NaN;
        % -----
        % Mount/construct a patch for each level of annotation
        for intensity = 0:3
            % -----
            % Get the onset and duration of each block of activity
            [onset, duration] = getBouts(x == intensity);
            onset = y(onset);
            duration = (duration*app.ACT.epoch)/(24*60*60);
            % Construct X and Y data
            XData = di;
            YData = -1/24;
            for oi = 1:length(onset)
                XData = [XData, di, di+0.33, di+0.33, di];
                YData = [YData, onset(oi), onset(oi), onset(oi)+duration(oi), onset(oi)+duration(oi)];
            end
            XData = [XData, di];
            YData = mod([YData, 1/24], 1)*24;
            % -----
            % Check if component should mount
            if shouldComponentMount(app, parent, ['DailyStats_PatchOverviewAnnotation_day-', num2str(di), '_int-', num2str(intensity)])
                % Define the properties
                props = { ...
                    'Tag', ['DailyStats_PatchOverviewAnnotation_day-', num2str(di), '_int-', num2str(intensity)]; ...
                    'XData', XData; ...
                    'YData', YData; ...
                    'FaceColor', annotClrs(intensity+1, :);...
                    'LineStyle', 'none'; ...
                    };
                % Mount component using the 'mount_patch' function
                mountComponent(app, 'mount_patch', parent, props);
            else
                % Construct the component with its updated X and YData
                constructComponent(app, ['DailyStats_PatchOverviewAnnotation_day-', num2str(di), '_int-', num2str(intensity)], parent, { ...
                    'XData', XData; ...
                    'YData', YData; ...
                    'LineStyle', 'none'; ...
                    });
            end
        end
    end
    % -----
    % Plot max and min euclidean norm in 5h moving windows
    % -----
    for varName = {'Min', 'Max'}
        % Extract the clock onset value
        YData = app.ACT.stats.daily.(['clockOnset' varName{:} 'EuclNormMovWin5h']){di};
        % Only mount/construct if the value is not 'na'
        if ~strcmpi(YData, 'na')
            % Construct X and Y data
            add = ifelse(any(app.ACT.analysis.annotate.Data ~= 0), 0.33, 0.1);
            XData = ifelse(strcmpi(varName{:}, 'Min'), [di + add, di + add], [di - 0.33, di - 0.33]);
            YData = mod(datenum(YData, 'dd/mm/yyyy HH:MM'), 1) * 24;
            YData = [YData, YData + 5];
            % -----
            % Check if component should mount
            if shouldComponentMount(app, parent, ['DailyStats_Plot' varName{:} 'EuclNormMovWin5h_day-', num2str(di)])
                % Define the properties
                props = {...
                    'Tag', ['DailyStats_Plot' varName{:} 'EuclNormMovWin5h_day-', num2str(di)]; ...
                    'XData', XData; ...
                    'YData', YData; ...
                    'LineStyle', '-'; ...
                    'LineWidth', 1; ...
                    'Color', ifelse(strcmpi(varName{:}, 'Min'), [0.0936, 0.5848, 0.6030], [0.0222, 0.4983, 0.1330]); ...
                    'Marker', 'none'; ...
                    };
                % Mount component using the 'mount_plot' function
                mountComponent(app, 'mount_plot', parent, props);
            else
                % Construct the component with its updated X and YData
                constructComponent(app, ['DailyStats_Plot' varName{:} 'EuclNormMovWin5h_day-', num2str(di)], parent, {...
                    'XData', XData; ...
                    'YData', YData; ...
                    });
            end
        end
    end
    % -----
    % Append TickMarkData with today's tickmarks
    TickMarkXData = [TickMarkXData, zeros(1, length(0:2:24))+di];
    TickMarkYData = [TickMarkYData, 0:2:24];
end
% -----
% TickMarks
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'DailyStats_UIAxesTickMarks')
    % Define the properties
    props = {...
        'Tag', 'DailyStats_UIAxesTickMarks'; ...
        'XData', TickMarkXData; ...
        'YData', TickMarkYData; ...
        'LineStyle', 'none'; ...
        'LineWidth', 1; ...
        'Color', 'w'; ...
        'Marker', 'o'; ...
        'MarkerFaceColor', [0.70, 0.33, 0.78]; ...
        'MarkerSize', 4; ...
        };
    % Mount component using the 'mount_plot' function
    mountComponent(app, 'mount_plot', parent, props);
else
    % Construct the component with its updated X and YData
    constructComponent(app, 'DailyStats_UIAxesTickMarks', parent, {...
        'XData', TickMarkXData; ...
        'YData', TickMarkYData; ...
        });
end

% ---------------------------------------------------------
% Table 
% ---------------------------------------------------------
% Panel
% -----
% Check if component should mount
if shouldComponentMount(app, app.GridLayoutDailyStats_Container, 'DailyStats_Panel')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 2;
    Layout.Column = [1, 12];
    % Define the properties
    props = {...
        'Tag', 'DailyStats_Panel'; ...
        'Title', ''; ...
        'BackgroundColor', [1, 1, 1]; ...
        'Layout', Layout; ...
        };
    % Mount component using the 'mount_uipanel' function
    mountComponent(app, 'mount_uipanel', app.GridLayoutDailyStats_Container, props);
end
% -----
% Extract parent panel object to use for its children
parent = findobj(app.GridLayoutDailyStats_Container.Children, 'Tag', 'DailyStats_Panel');
% -----
% GridLayout
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'DailyStats_GridLayout')
    % Define the properties
    props = {...
        'Tag', 'DailyStats_GridLayout'; ...
        'ColumnWidth', [{125}, repmat({53}, 1, size(app.ACT.stats.daily, 1))]; ...
        'RowHeight', repmat({21}, 1, size(app.ACT.stats.daily, 2)); ...
        'ColumnSpacing', 3; ...
        'RowSpacing', 0; ...
        'Padding', [0, 0, 0, 0]; ...
        'Scrollable', 'on'; ...
        };
    % Mount component using the 'mount_uigridlayout' function
    mountComponent(app, 'mount_uigridlayout', parent, props);
end
% -----
% Extract parent girdlayout object to use for its children
parent = findobj(parent.Children, 'Tag', 'DailyStats_GridLayout');
% Extract all the variable names from the daily analysis table
fnames = app.ACT.stats.daily.Properties.VariableNames;
% -----
% For each fieldname ...
for fi = 1:length(fnames)
    % -----
    % For each day ...
    for di = 1:size(app.ACT.stats.daily, 1)
        % -----
        % ... mount/construct a label of the variable value
        % -----
        value = app.ACT.stats.daily.(fnames{fi})(di);
        % Format the Text, Color and Label
        switch fnames{fi}
            case 'date'
                Text = value{:}(1:5);
                Color = [0.13, 0.38, 0.19];
                Label = 'Date';
            case 'day'
                Text = value{:};
                Color = [0.13, 0.38, 0.19];
                Label = 'Day';
            case 'hoursValidData'
                Text = duration2str(value/24);
                Color = [0.13, 0.38, 0.19];
                Label = 'Valid data';
            case 'hoursReject'
                Text = ifelse(value == 0, '-', duration2str(value/24));
                Color = [0.13, 0.38, 0.19];
                Label = 'Reject time';
            case 'avEuclNorm'
                Text = sprintf('%.0f mg', value*1000);
                Color = [0.49, 0.18, 0.56];
                Label = 'Mean Eucl. Norm';
            case 'maxEuclNormMovWin5h'
                Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
                Color = [0.49, 0.18, 0.56];
                Label = 'Activity level in M5';
            case 'clockOnsetMaxEuclNormMovWin5h'
                Text = ifelse(strcmp(value{:}, 'na'), '-', value{:}(regexp(value{:}, '[0-9]+:[0-9]+'):end));
                Color = [0.49, 0.18, 0.56];
                Label = 'Clock onset M5';
            case 'minEuclNormMovWin5h'
                Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
                Color = [0.49, 0.18, 0.56];
                Label = 'Activity level in L5';
            case 'clockOnsetMinEuclNormMovWin5h'
                Text = ifelse(strcmp(value{:}, 'na'), '-', value{:}(regexp(value{:}, '[0-9]+:[0-9]+'):end));
                Color = [0.49, 0.18, 0.56];
                Label = 'Clock onset L5';
            case 'hoursModVigAct'
                Text = ifelse(value == 0, '-', duration2str(value/24));
                Color = [0.49, 0.18, 0.56];
                Label = 'Mod/vig activity time';
            case 'avEuclNormModVigAct'
                Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
                Color = [0.49, 0.18, 0.56];
                Label = 'Mod/vig activity level';
            case 'slpAcrossNoon'
                Text = ifelse(isnan(value), '-', ifelse(value == 1, 'yes', 'no'));
                Color = [0.00, 0.24, 0.56];
                Label = 'Slept across noon';
            case 'avLightW'
                Text = ifelse(isnan(value), '-', sprintf('%.0f lux', value));
                Color = [0.15, 0.15, 0.15];
                Label = 'Light - mean';
            case 'minLightWMovWin30m'
                Text = ifelse(isnan(value), '-', sprintf('%.0f lux', value));
                Color = [0.15, 0.15, 0.15];
                Label = 'Min';
            case 'maxLightWMovWin30m'
                Text = ifelse(isnan(value), '-', sprintf('%.0f lux', value));
                Color = [0.15, 0.15, 0.15];
                Label = 'Max';
            case 'clockOnsetMinLightWMovWin30m'
                Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                Color = [0.15, 0.15, 0.15];
                Label = 'Clock onset min';
            case 'clockOnsetMaxLightWMovWin30m'
                Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                Color = [0.15, 0.15, 0.15];
                Label = 'Clock onset max';
            case 'avTemperatureWrist'
                Text = ifelse(isnan(value), '-', sprintf('%.0f *C', value));
                Color = [0.15, 0.15, 0.15];
                Label = 'Temperature - mean';
            case 'minTemperatureWristMovWin30m'
                Text = ifelse(isnan(value), '-', sprintf('%.0f *C', value));
                Color = [0.15, 0.15, 0.15];
                Label = 'Min';
            case 'maxTemperatureWristMovWin30m'
                Text = ifelse(isnan(value), '-', sprintf('%.0f *C', value));
                Color = [0.15, 0.15, 0.15];
                Label = 'Max';
            case 'clockOnsetMinTemperatureWristMovWin30m'
                Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                Color = [0.15, 0.15, 0.15];
                Label = 'Clock onset min';
            case 'clockOnsetMaxTemperatureWristMovWin30m'
                Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                Color = [0.15, 0.15, 0.15];
                Label = 'Clock onset max';
        end
        % Check if component should mount
        if shouldComponentMount(app, parent, ['DailyStats_Value-', fnames{fi}, '_day-', num2str(di)])
            % Set Layout
            Layout = app.DataPanel.Layout;
            Layout.Row = fi;
            Layout.Column = di+1;
            % Define the properties
            props = {...
                'Tag', ['DailyStats_Value-', fnames{fi}, '_day-', num2str(di)]; ...
                'Text', Text; ...
                'FontColor', Color; ...
                'HorizontalAlignment', 'center'; ...
                'Layout', Layout; ...
                };
            % Mount component using the 'mount_uilabel' function
            mountComponent(app, 'mount_uilabel', parent, props);
        else
            % Construct the component with its updated X and YData
            constructComponent(app, ['DailyStats_Value-', fnames{fi}, '_day-', num2str(di)], parent, {...
                'Text', Text; ...
                'FontColor', Color; ...
                });
        end
    end
    % -----
    % ... mount/construct a label
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['DailyStats_Label-', fnames{fi}])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = fi;
        Layout.Column = 1;
        % Define the properties
        props = {...
            'Tag', ['DailyStats_Label-', fnames{fi}]; ...
            'Text', Label; ...
            'HorizontalAlignment', 'right'; ...
            'Layout', Layout; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_uilabel', parent, props);
    end
end

end %EOF
