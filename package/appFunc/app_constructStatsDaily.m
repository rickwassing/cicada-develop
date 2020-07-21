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
    Layout.Column = 1;
    % Define the properties
    props = { ...
        'Tag', 'DailyStats_UIAxesOverview'; ...
        'XLim', [0, 24]; ...
        'XTick', 0:2:24; ...
        'XTickLabel', datestr(0:2/24:1, 'HH:MM'); ...
        'XGrid', 'on'; ...
        'YDir', 'reverse'; ...
        'YLim', [0.5, max([size(app.ACT.stats.daily, 1), 14])+0.5]; ...
        'YTick', 1:size(app.ACT.stats.daily, 1); ...
        'YTickLabel', cellfun(@(x) x(1:end-5), app.ACT.stats.daily.date, 'UniformOutput', false); ...
        'BackgroundColor', [0.95, 0.95, 0.95]; ...
        'XColor', [0.70, 0.33, 0.78]; ...
        'YColor', [0.30, 0.60, 0.46]; ...
        'Layout', Layout; ...
        'Layer', 'top'; ...
        'FontSize', 10; ...
        'Box', 'on'; ...
        };
    % Mount component using the 'mount_uiaxes' function
    Cursor = mountComponent(app, 'mount_uiaxes', app.GridLayoutDailyStats_Container, props, true);
    Cursor.XLabel.String = '< am - pm >';
end
% -----
% Extract parent axes object to use for its children
parent = findobj(app.GridLayoutDailyStats_Container.Children, 'Tag', 'DailyStats_UIAxesOverview');
% -----
% Patch Current Selection
% -----
if shouldComponentMount(app, app.GridLayoutDailyStats_Container, 'DailyStats_PatchCurrentSelection')
    % -----
    % Get X and YData
    XData = [0, 24, 24, 0];
    YData = [1, 1, 1, 1] + [-0.4175, -0.4175, 0.4175, 0.4175];
    % Get UserData
    UserData.select = 1;
    % Define the properties
    props = {...
        'Tag', 'DailyStats_PatchCurrentSelection'; ...
        'XData', XData; ...
        'YData', YData; ...
        'FaceColor', [0.1765, 0.3725, 0.6745]; ...
        'FaceAlpha', 0.15; ...
        'LineStyle', 'none'; ...
        'UserData', UserData; ...
        'PickableParts', 'none'; ...
        };
    % Mount component using the 'mount_patch' function
    Cursor = mountComponent(app, 'mount_patch', parent, props);
else
    Cursor = findobj(parent.Children, 'Tag', 'DailyStats_PatchCurrentSelection');
    % Construct the component with its updated YData
    constructComponent(app, 'DailyStats_PatchCurrentSelection', parent, {...
        'YData', repmat(Cursor.UserData.select, 1, 4) + [-0.4175, -0.4175, 0.4175, 0.4175]; ...
        });
end
% -----
% Patch Euclidean Norm
% -----
% Get X and YData
XData = app.ACT.metric.acceleration.bpFiltEuclNorm.Time;
addToYData = ceil(XData) - floor(XData(1));
XData = [mod(XData, 1)*24; NaN];
YData = [-map(app.ACT.metric.acceleration.bpFiltEuclNorm.Data, ...
    0, app.ACT.display.acceleration.euclNorm.range(2), ...
    -0.24, 0.33, true) + addToYData; NaN];
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'DailyStats_PatchOverviewEuclNorm')
    % Define the properties
    props = {...
        'Tag', 'DailyStats_PatchOverviewEuclNorm'; ...
        'XData', XData; ...
        'YData', YData; ...
        'CData', -1*(YData - [addToYData; NaN]); ...
        'FaceColor', 'none'; ...
        'EdgeColor', 'interp'; ...
        'LineStyle', '-'; ...
        'PickableParts', 'none'; ...
        };
    % Mount component using the 'mount_patch' function
    mountComponent(app, 'mount_patch', parent, props);
else
    % Construct the component with its updated X, Y and CData
    constructComponent(app, 'DailyStats_PatchOverviewEuclNorm', parent, {...
        'XData', XData; ...
        'YData', YData; ...
        'CData', -1*(YData - [addToYData; NaN]); ...
        });
end
% -----
% Plot max and min euclidean norm in 5h moving windows
% -----
% For each day ...
for di = 1:size(app.ACT.stats.daily, 1)
    for varName = {'Min', 'Max'}
        % Only mount/construct if the value is not 'na'
        XData = app.ACT.stats.daily.(['clockOnset' varName{:} 'EuclNormMovWin5h']){di};
        if ~strcmpi(XData, 'na')
            % Construct X and Y data
            XData = datenum(XData, 'dd/mm/yyyy HH:MM');
            YData = ceil(XData) - floor(app.ACT.xmin);
            YData = ifelse(strcmpi(varName{:}, 'Min'), [YData+1.33, YData+1.33, NaN, YData+0.33, YData+0.33, NaN], [YData + 0.66, YData + 0.66, NaN, YData - 0.33, YData - 0.33, NaN]);
            XData = mod(XData, 1) * 24;
            XData = [XData-24, XData - 24 + 5, NaN, XData, XData + 5, NaN];
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
                    'Color', ifelse(strcmpi(varName{:}, 'Min'), [0.2764, 0.3814, 0.6656], [0.9466, 0.6142, 0.4198]); ...
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
    Layout.Row = 1;
    Layout.Column = 2;
    % Define the properties
    props = {...
        'Tag', 'DailyStats_Panel'; ...
        'Title', ''; ...
        'FontSize', 11; ...
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
        'ColumnWidth', [{175}, '1x']; ...
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
    % ... mount/construct a label of the variable value
    % -----
    value = app.ACT.stats.daily.(fnames{fi})(Cursor.UserData.select);
    % Format the Text, Color and Label
    switch fnames{fi}
        case 'date'
            Text = value{:}(1:5);
            Color = [0.13, 0.38, 0.19];
        case 'day'
            Text = value{:};
            Color = [0.13, 0.38, 0.19];
        case 'hoursValidData'
            Text = duration2str(value/24);
            Color = [0.13, 0.38, 0.19];
        case 'hoursReject'
            Text = ifelse(value == 0, '-', duration2str(value/24));
            Color = [0.13, 0.38, 0.19];
        case 'avEuclNorm'
            Text = sprintf('%.0f mg', value*1000);
            Color = [0.49, 0.18, 0.56];
        case 'maxEuclNormMovWin5h'
            Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
            Color = [0.49, 0.18, 0.56];
        case 'clockOnsetMaxEuclNormMovWin5h'
            Text = ifelse(strcmp(value{:}, 'na'), '-', value{:}(regexp(value{:}, '[0-9]+:[0-9]+'):end));
            Color = [0.49, 0.18, 0.56];
        case 'minEuclNormMovWin5h'
            Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
            Color = [0.49, 0.18, 0.56];
        case 'clockOnsetMinEuclNormMovWin5h'
            Text = ifelse(strcmp(value{:}, 'na'), '-', value{:}(regexp(value{:}, '[0-9]+:[0-9]+'):end));
            Color = [0.49, 0.18, 0.56];
        case 'hoursModVigAct'
            Text = ifelse(value == 0, '-', duration2str(value/24));
            Color = [0.49, 0.18, 0.56];
        case 'avEuclNormModVigAct'
            Text = ifelse(isnan(value), '-', sprintf('%.0f mg', value*1000));
            Color = [0.49, 0.18, 0.56];
        case 'slpAcrossNoon'
            Text = ifelse(isnan(value), '-', ifelse(value == 1, 'yes', 'no'));
            Color = [0.00, 0.24, 0.56];
        otherwise
            if isnumeric(value)
                Text = ifelse(isnan(value), '-', sprintf('%.0f', value));
                Color = [0.15, 0.15, 0.15];
                Label = fnames{fi};
            elseif iscell(value)
                Text = ifelse(strcmp(value{:}, 'na'), '-', value{:});
                Color = [0.15, 0.15, 0.15];
                Label = fnames{fi};
            end
    end
    % -----
    % ... mount/construct a label
    % -----
    % Set Text
    Label = fnames{fi};
    if strRegexpCheck(Label, '^min')
        Label = 'Min';
        FontWeight = 'normal';
    elseif strRegexpCheck(Label, '^max')
        Label = 'Max';
        FontWeight = 'normal';
    elseif strRegexpCheck(Label, '^clockOnset')
        Label = 'Clock Onset';
        FontWeight = 'normal';
    else
        FontWeight = 'bold';
    end
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = fi;
    Layout.Column = 1;
    % Check if component should mount
    if shouldComponentMount(app, parent, ['DailyStats_Label-', fnames{fi}])
        % Define the properties
        props = {...
            'Tag', ['DailyStats_Label-', fnames{fi}]; ...
            'Text', Label; ...
            'FontWeight', FontWeight; ...
            'FontColor', Color; ...
            'HorizontalAlignment', 'right'; ...
            'Layout', Layout; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_uilabel', parent, props);
    else
        % Construct the component with its updated X and YData
        constructComponent(app, ['DailyStats_Label-', fnames{fi}], parent, {...
            'Layout', Layout; ...
            'Text', Label; ...
            'FontWeight', FontWeight; ...
            });
    end
    % -----
    % ... mount/construct the value
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['DailyStats_Value-', fnames{fi}])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = fi;
        Layout.Column = 2;
        % Define the properties
        props = {...
            'Tag', ['DailyStats_Value-', fnames{fi}]; ...
            'Text', Text; ...
            'FontColor', Color; ...
            'HorizontalAlignment', 'center'; ...
            'Layout', Layout; ...
            };
        % Mount component using the 'mount_uilabel' function
        mountComponent(app, 'mount_uilabel', parent, props);
    else
        % Construct the component with its updated X and YData
        constructComponent(app, ['DailyStats_Value-', fnames{fi}], parent, {...
            'Text', Text; ...
            'FontColor', Color; ...
            });
    end
    
end

end %EOF
