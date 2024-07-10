function app_constructStatsAverage(app)

% ---------------------------------------------------------
% Enable/Disable the ReAnalyse buttons if required
if isempty(app.ACT.filename)
    app.AvStats_RegenStatsButton.Enable = 'off';
    app.AvStats_RegenStatsButton.Text = 'Generate Statistics';
    app.AvStats_FilterPanel.Visible = 'off';
    app.AvStats_Container.Visible = 'off';
    return
elseif ~isfield(app.ACT.stats, 'average')
    app.AvStats_RegenStatsButton.Enable = 'on';
    app.AvStats_RegenStatsButton.Text = 'Generate Statistics';
    app.AvStats_FilterPanel.Visible = 'off';
    app.AvStats_Container.Visible = 'off';
    return
else
    app.AvStats_RegenStatsButton.Enable = 'off';
    app.AvStats_RegenStatsButton.Text = 'Statistics Up-To-Date';
    app.AvStats_FilterPanel.Visible = 'on';
    app.AvStats_Container.Visible = 'on';
end

% ---------------------------------------------------------
% Get which days we should consider, all, week, or weekend
switch app.AvStats_FilterPanelButtonGroup.SelectedObject.Text
    case 'all days'
        select = 'all';
        selectDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
    case 'weekdays only'
        select = 'week';
        selectDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};
    case 'weekends only'
        select = 'weekend';
        selectDays = {'Sat', 'Sun'};
end

% ---------------------------------------------------------
% Inter-daily stability and intra-daily variability
if isnan(app.ACT.stats.average.(select).interDailyStability) || isnan(app.ACT.stats.average.(select).intraDailyVariability)
    app.AvStats_InterIntraDailyPanel.Visible = 'off';
else
    app.AvStats_InterIntraDailyPanel.Visible = 'on';
    % ---------------------------------------------------------
    % DailyStability
    % ---------------------------------------------------------
    % UIAxes
    % -----
    % Check if component should mount
    if shouldComponentMount(app, app.AvStats_GridLayoutInterIntraDailyPanel, 'AvStats_UIAxesDailyStability')
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = 1;
        Layout.Column = 1;
        % Define the properties
        props = { ...
            'Tag', 'AvStats_UIAxesDailyStability'; ...
            'XLim', [0, 1]; ...
            'XTick', [0, 1]; ...
            'XTickLabel', [0, 1]; ...
            'YLim', [0.5 1.5]; ...
            'YTick', []; ...
            'YTickLabel', []; ...
            'BackgroundColor', [1, 1, 1]; ...
            'XColor', [0.30, 0.60, 0.46]; ...
            'YColor', [0.30, 0.60, 0.46]; ...
            'Layout', Layout; ...
        	'Layer', 'top'; ...
            'FontSize', 8; ...
            'Box', 'on'; ...
            };
        % Mount component using the 'mount_uiaxes' function
        Component = mountComponent(app, 'mount_uiaxes', app.AvStats_GridLayoutInterIntraDailyPanel, props);
        Component.Title.String = 'Inter-Daily Stability';
        Component.Title.FontSize = 10;
    end
    % -----
    % Extract parent axes object to use for its children
    parent = findobj(app.AvStats_GridLayoutInterIntraDailyPanel.Children, 'Tag', 'AvStats_UIAxesDailyStability');
    % ---------------------------------------------------------
    % Horizontal Bar Graph
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, 'AvStats_BarHDailyStability')
        % Define the properties
        props = { ...
            'Tag', 'AvStats_BarHDailyStability'; ...
            'YData', app.ACT.stats.average.(select).interDailyStability; ...
            'FaceColor', [0.13, 0.38, 0.19]; ...
            'BarWidth', 1; ...
            };
        % Mount component using the 'mount_barh' function
        mountComponent(app, 'mount_barh', parent, props);
    else
        % Construct the component with its updated YData
        constructComponent(app, 'AvStats_BarHDailyStability', parent, { ...
            'YData', app.ACT.stats.average.(select).interDailyStability; ...
            });
    end
    % ---------------------------------------------------------
    % Text object showing the inter-daily stability value
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, 'AvStats_TextDailyStability')
        % Define the properties
        position = app.ACT.stats.average.(select).interDailyStability;
        props = { ...
            'Tag', 'AvStats_TextDailyStability'; ...
            'Color', ifelse(position < 0.75, 'k', 'w'); ...
            'FontSize', 10; ...
            'FontWeight', 'bold'; ...
            'HorizontalAlignment', ifelse(position < 0.75, 'left', 'right'); ...
            'VerticalAlignment', 'middle'; ...
            'String', sprintf('  %.2f  ', position); ...
            'Position', [position, 1 , 0]; ...
            'Margin', 10;...
            };
        % Mount component using the 'mount_text' function
        mountComponent(app, 'mount_text', parent, props);
    else
        % Construct the component with its updated Color, HorAlign, String, and Position
        position = app.ACT.stats.average.(select).interDailyStability;
        constructComponent(app, 'AvStats_TextDailyStability', parent, { ...
            'Color', ifelse(position < 0.75, 'k', 'w'); ...
            'HorizontalAlignment', ifelse(position < 0.75, 'left', 'right'); ...
            'String', sprintf('  %.2f  ', position); ...
            'Position', [position, 1 , 0]; ...
            });
    end
    % ---------------------------------------------------------
    % DailyVariability
    % ---------------------------------------------------------
    % UIAxes
    % -----
    % Check if component should mount
    if shouldComponentMount(app, app.AvStats_GridLayoutInterIntraDailyPanel, 'AvStats_UIAxesDailyVariability')
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = 1;
        Layout.Column = 2;
        % Define the properties
        props = { ...
            'Tag', 'AvStats_UIAxesDailyVariability'; ...
            'XLim', [0, ceil(app.ACT.stats.average.(select).intraDailyVariability*2)/2+0.5]; ...
            'XTick', 0:0.5:ceil(app.ACT.stats.average.(select).intraDailyVariability*2)/2+0.5; ...
            'XTickLabel', 0:0.5:ceil(app.ACT.stats.average.(select).intraDailyVariability*2)/2+0.5; ...
            'YLim', [0.5 1.5]; ...
            'YTick', []; ...
            'YTickLabel', []; ...
            'BackgroundColor', [1, 1, 1]; ...
            'XColor', [0.30, 0.60, 0.46]; ...
            'YColor', [0.30, 0.60, 0.46]; ...
            'Layout', Layout; ...
        	'Layer', 'top'; ...
            'FontSize', 8; ...
            'Box', 'on'; ...
            };
        % Mount component using the 'mount_uiaxes' function
        Component = mountComponent(app, 'mount_uiaxes', app.AvStats_GridLayoutInterIntraDailyPanel, props);
        Component.Title.String = 'Intra-Daily Variability';
        Component.Title.FontSize = 10;
    else
        % Construct the component with its updated XLim, XTick, and XTickLabel
        constructComponent(app, 'AvStats_UIAxesDailyVariability', app.AvStats_GridLayoutInterIntraDailyPanel, { ...
            'XLim', [0, ceil(app.ACT.stats.average.(select).intraDailyVariability*2)/2+0.5]; ...
            'XTick', 0:0.5:ceil(app.ACT.stats.average.(select).intraDailyVariability*2)/2+0.5; ...
            'XTickLabel', 0:0.5:ceil(app.ACT.stats.average.(select).intraDailyVariability*2)/2+0.5; ...
            });
    end
    % -----
    % Extract parent axes object to use for its children
    parent = findobj(app.AvStats_GridLayoutInterIntraDailyPanel.Children, 'Tag', 'AvStats_UIAxesDailyVariability');
    % ---------------------------------------------------------
    % Horizontal Bar Graph
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, 'AvStats_BarHDailyVariability')
        % Define the properties
        props = { ...
            'Tag', 'AvStats_BarHDailyVariability'; ...
            'YData', app.ACT.stats.average.(select).intraDailyVariability; ...
            'FaceColor', [0.13, 0.38, 0.19]; ...
            'BarWidth', 1; ...
            };
        % Mount component using the 'mount_barh' function
        mountComponent(app, 'mount_barh', parent, props);
    else
        % Construct the component with its updated YData
        constructComponent(app, 'AvStats_BarHDailyVariability', parent, { ...
            'YData', app.ACT.stats.average.(select).intraDailyVariability; ...
            });
    end
    % ---------------------------------------------------------
    % Text object showing the inter-daily stability value
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, 'AvStats_TextDailyVariability')
        % Define the properties
        position = app.ACT.stats.average.(select).intraDailyVariability;
        props = { ...
            'Tag', 'AvStats_TextDailyVariability'; ...
            'Color', 'k'; ...
            'FontSize', 10; ...
            'FontWeight', 'bold'; ...
            'HorizontalAlignment', 'left'; ...
            'VerticalAlignment', 'middle'; ...
            'String', sprintf('  %.2f  ', position); ...
            'Position', [position, 1 , 0]; ...
            'Margin', 10; ...
            };
        % Mount component using the 'mount_text' function
        mountComponent(app, 'mount_text', parent, props);
    else
        % Construct the component with its updated String, and Position
        position = app.ACT.stats.average.(select).intraDailyVariability;
        constructComponent(app, 'AvStats_TextDailyVariability', parent, { ...
            'String', sprintf('  %.2f  ', position); ...
            'Position', [position, 1 , 0]; ...
            });
    end
end

% ---------------------------------------------------------
% Plot Daily average patches
% ---------------------------------------------------------
% EuclNorm
app_constructStatsAverageDayGraph(app, app.AvStats_GridLayoutAccelerationPanel, app.ACT.analysis.average.(select).activityMovWin5h, ...
    'euclNormMovWin5h', 'mg', 1000, ...
    app.ACT.stats.average.(select).clockOnsetMaxActivityMovWin10h, ...
    app.ACT.stats.average.(select).clockOnsetMinActivityMovWin5h, ...
    app.ACT.stats.average.(select).maxActivityMovWin10h, ...
    app.ACT.stats.average.(select).minActivityMovWin5h)
% ---------------------------------------------------------
% Light
% -----
% Find the first 'Light' variable, as we assume this is the most important one
% *****
% * ISSUE #1
% *****
% * ISSUE #2
% *****
fnames = fieldnames(app.ACT.analysis.average.(select));
fi = strRegexpCheck(fnames, 'light.+MovWin30m');
if any(fi)
    tableVarName = fnames{find(fi, 1, 'first')};
    tableVarName(1) = upper(tableVarName(1));
    app_constructStatsAverageDayGraph(app, app.AvStats_GridLayoutLightPanel, app.ACT.analysis.average.(select).(fnames{find(fi, 1, 'first')}), ...
        fnames{find(fi, 1, 'first')}, 'lux', 1, ...
        app.ACT.stats.average.(select).(['clockOnsetMax', tableVarName]), ...
        app.ACT.stats.average.(select).(['clockOnsetMin', tableVarName]), ...
        app.ACT.stats.average.(select).(['max', tableVarName]), ...
        app.ACT.stats.average.(select).(['min', tableVarName]))
end
% ---------------------------------------------------------
% Temperature
% -----
% Find the first 'Temperature' variable, as we assume this is the most important one
fnames = fieldnames(app.ACT.analysis.average.(select));
fi = strRegexpCheck(fnames, 'temperature.+MovWin30m');
if any(fi)
    tableVarName = fnames{find(fi, 1, 'first')};
    tableVarName(1) = upper(tableVarName(1));
    app_constructStatsAverageDayGraph(app, app.AvStats_GridLayoutTemperaturePanel, app.ACT.analysis.average.(select).(fnames{find(fi, 1, 'first')}), ...
        fnames{find(fi, 1, 'first')}, '*C', 1, ...
        app.ACT.stats.average.(select).(['clockOnsetMax', tableVarName]), ...
        app.ACT.stats.average.(select).(['clockOnsetMin', tableVarName]), ...
        app.ACT.stats.average.(select).(['max', tableVarName]), ...
        app.ACT.stats.average.(select).(['min', tableVarName]))
end
% ---------------------------------------------------------
% Set Text values of the Stats Info Panel
app.AvStats_NumberofDaysValue.Text = num2str(sum(ismember(app.ACT.stats.daily.day, selectDays)));
app.AvStats_ActogramWindowValue.Text  = [datestr(app.ACT.startdate, 'HH:MM'), ' - ', datestr(app.ACT.enddate, 'HH:MM')];
app.AvStats_TimeRejectedValue.Text = duration2str(app.ACT.stats.average.(select).hoursReject./24);

% ---------------------------------------------------------
% Set Text values of the Acceleration Panel
if app.ACT.stats.average.(select).hoursModVigAct > 0 && isfield(app.ACT.analysis.annotate, 'acceleration')
    app.AvStats_HoursModVigActValue.Text = duration2str(app.ACT.stats.average.(select).hoursModVigAct/24);
    app.AvStats_AvActivityModVigActValue.Text = sprintf('%.0f mg', app.ACT.stats.average.(select).avActivityModVigAct*1000);
else
    app.AvStats_HoursModVigActValue.Text = '-';
    app.AvStats_AvActivityModVigActValue.Text = '-';
end

% ---------------------------------------------------------
% If there is no sleep analysis, do not show the sleep statistics
if ~isfield(app.ACT.stats, 'sleep')
    app.AvStats_SleepPanel.Visible = 'off';
    return
elseif ~isfield(app.ACT.stats.sleep, 'actigraphy')
    app.AvStats_SleepPanel.Visible = 'off';
    return
else
    app.AvStats_SleepPanel.Visible = 'on';
end

% ---------------------------------------------------------
% SleepClock
% ---------------------------------------------------------
% UIAxes
% -----
% Check if component should mount
if shouldComponentMount(app, app.AvStats_GridLayoutSleepPanel, 'AvStats_UIAxesSleepClock')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = [1, 6];
    Layout.Column = 2;
    % Define the properties
    props = { ...
        'Tag', 'AvStats_UIAxesSleepClock'; ...
        'XLim', [-11, 11]; ...
        'XTick', []; ...
        'XTickLabel', []; ...
        'YLim', [-11, 11]; ...
        'YTick', []; ...
        'YTickLabel', []; ...
        'BackgroundColor', [1, 1, 1]; ...
        'XColor', [1, 1, 1]; ...
        'YColor', [1, 1, 1]; ...
        'Layout', Layout; ...
        'Layer', 'top'; ...
        'FontSize', 8; ...
        'NextPlot', 'add'; ...
        'PlotBoxAspectRatio', [1, 1, 1]; ...
        'Box', 'off'; ...
        };
    % Mount component using the 'mount_uiaxes' function
    mountComponent(app, 'mount_uiaxes', app.AvStats_GridLayoutSleepPanel, props);
end
% -----
% Extract parent axes object to use for its children
parent = findobj(app.AvStats_GridLayoutSleepPanel.Children, 'Tag', 'AvStats_UIAxesSleepClock');
% -----
% The clock as too many components to mount/construct so simply delete the clock and plot it again
delete(parent.Children)
% -----
% Get the data for the sleep clock
try
    SleepWindowAct = [datenum(app.ACT.stats.average.(select).avClockLightsOutAct, 'HH:MM'), datenum(app.ACT.stats.average.(select).avClockLightsOnAct, 'HH:MM')];
catch
    SleepWindowAct = [];
end
try
    SleepPeriodAct = [datenum(app.ACT.stats.average.(select).avClockSlpOnsetAct, 'HH:MM'), datenum(app.ACT.stats.average.(select).avClockFinAwakeAct, 'HH:MM')];
catch
    SleepPeriodAct = [];
end
try
    AwakeningAct = waso2bouts(...
        app.ACT.stats.average.(select).avWakeAfterSlpOnsetAct, ...
        app.ACT.stats.average.(select).avAwakeningAct, ...
        datenum(app.ACT.stats.average.(select).avClockSlpOnsetAct, 'HH:MM'), ...
        datenum(app.ACT.stats.average.(select).avClockFinAwakeAct, 'HH:MM'));
catch
    AwakeningAct = [];
end
try
    SleepWindowDiary = [datenum(app.ACT.stats.average.(select).avClockLightsOutDiary, 'HH:MM'), datenum(app.ACT.stats.average.(select).avClockLightsOnDiary, 'HH:MM')];
catch
    SleepWindowDiary = [];
end
try
    SleepPeriodDiary = [datenum(app.ACT.stats.average.(select).avClockSlpOnsetDiary, 'HH:MM'), datenum(app.ACT.stats.average.(select).avClockFinAwakeDiary, 'HH:MM')];
catch
    SleepPeriodDiary = [];
end
try
    AwakeningDiary = waso2bouts(...
        app.ACT.stats.average.(select).avWakeAfterSlpOnsetDiary, ...
        app.ACT.stats.average.(select).avAwakeningDiary, ...
        datenum(app.ACT.stats.average.(select).avClockSlpOnsetDiary, 'HH:MM'), ...
        datenum(app.ACT.stats.average.(select).avClockFinAwakeDiary, 'HH:MM'));
catch
    AwakeningDiary = [];
end
% -----
% Mount all components directly using the 'mount_sleepClock' function
mount_sleepClock(app, parent, ...
    'Tag', 'AvStats_sleepClock', ...
    'SleepWindowAct', SleepWindowAct, ...
    'SleepPeriodAct', SleepPeriodAct, ...
    'AwakeningAct',  AwakeningAct, ...
    'SleepWindowDiary', SleepWindowDiary, ...
    'SleepPeriodDiary', SleepPeriodDiary, ...
    'AwakeningDiary', AwakeningDiary ...
    );

% ---------------------------------------------------------
% Set Text values of the Sleep Panel
app.AvStats_SlpCountValue.Text = num2str(app.ACT.stats.average.(select).count);
app.AvStats_SlpAcrossNoonValue.Text = [num2str(app.ACT.stats.average.(select).slpAcrossNoon), 'x'];

% ---------------------------------------------------------
% Set Text values of the Actigraphy Sleep variables
app.AvStats_LightsOutActValue.Text = app.ACT.stats.average.(select).avClockLightsOutAct;
app.AvStats_SlpOnsetLatActValue.Text = duration2str(app.ACT.stats.average.(select).avSlpOnsetLatAct/(24*60));
app.AvStats_WakeAfterSlpOnsetActValue.Text = duration2str(app.ACT.stats.average.(select).avWakeAfterSlpOnsetAct/(24*60));
app.AvStats_FinAwakeActValue.Text = app.ACT.stats.average.(select).avClockFinAwakeAct;
app.AvStats_LightsOnActValue.Text = app.ACT.stats.average.(select).avClockLightsOnAct;
app.AvStats_SlpWindowActValue.Text = duration2str(app.ACT.stats.average.(select).avSlpWindowAct/(24*60));
app.AvStats_SlpPeriodActValue.Text = duration2str(app.ACT.stats.average.(select).avSlpPeriodAct/(24*60));
app.AvStats_SlpTimeActValue.Text = duration2str(app.ACT.stats.average.(select).avTotSlpTimeAct/(24*60));
if ~isnan(app.ACT.stats.average.(select).avSlpEffSlpPeriodAct)
    app.AvStats_SlpEffSlpPeriodActValue.Text = sprintf('%.0f%%', app.ACT.stats.average.(select).avSlpEffSlpPeriodAct);
else
    app.AvStats_SlpEffSlpPeriodActValue.Text = '-';
end
if ~isnan(app.ACT.stats.average.(select).avSlpEffSlpTimeAct)
    app.AvStats_SlpEffSlpTimeActValue.Text = sprintf('%.0f%%', app.ACT.stats.average.(select).avSlpEffSlpTimeAct);
else
    app.AvStats_SlpEffSlpTimeActValue.Text = '-';
end
% ---------------------------------------------------------
% Set Text values of the Sleep Diary variables
if ~isfield(app.ACT.stats.sleep, 'sleepDiary') || ~app.ACT.stats.sleep.compareAverage
    app.AvStats_LegendDiaryLabel.Visible = 'off';
    app.AvStats_LightsOutDiaryValue.Visible = 'off';
    app.AvStats_SlpOnsetLatDiaryValue.Visible = 'off';
    app.AvStats_WakeAfterSlpOnsetDiaryValue.Visible = 'off';
    app.AvStats_FinAwakeDiaryValue.Visible = 'off';
    app.AvStats_LightsOnDiaryValue.Visible = 'off';
    app.AvStats_SlpWindowDiaryValue.Visible = 'off';
    app.AvStats_SlpPeriodDiaryValue.Visible = 'off';
    app.AvStats_SlpTimeDiaryValue.Visible = 'off';
    app.AvStats_SlpEffSlpPeriodDiaryValue.Visible = 'off';
    app.AvStats_SlpEffSlpTimeDiaryValue.Visible = 'off';
    app.AvStats_MismatchLabel.Visible = 'off';
    app.AvStats_MismatchSleepPeriodValue.Visible = 'off';
    app.AvStats_MismatchSleepTimeValue.Visible = 'off';
    return
else
    app.AvStats_LegendDiaryLabel.Visible = 'on';
    app.AvStats_LightsOutDiaryValue.Visible = 'on';
    app.AvStats_SlpOnsetLatDiaryValue.Visible = 'on';
    app.AvStats_WakeAfterSlpOnsetDiaryValue.Visible = 'on';
    app.AvStats_FinAwakeDiaryValue.Visible = 'on';
    app.AvStats_LightsOnDiaryValue.Visible = 'on';
    app.AvStats_SlpWindowDiaryValue.Visible = 'on';
    app.AvStats_SlpPeriodDiaryValue.Visible = 'on';
    app.AvStats_SlpTimeDiaryValue.Visible = 'on';
    app.AvStats_SlpEffSlpPeriodDiaryValue.Visible = 'on';
    app.AvStats_SlpEffSlpTimeDiaryValue.Visible = 'on';
    app.AvStats_MismatchLabel.Visible = 'on';
    app.AvStats_MismatchSleepPeriodValue.Visible = 'on';
    app.AvStats_MismatchSleepTimeValue.Visible = 'on';
end

% ---------------------------------------------------------
% Set Text values of the Sleep Diary variables
app.AvStats_LightsOutDiaryValue.Text = app.ACT.stats.average.(select).avClockLightsOutDiary;
app.AvStats_SlpOnsetLatDiaryValue.Text = duration2str(app.ACT.stats.average.(select).avSlpOnsetLatDiary/(24*60));
app.AvStats_WakeAfterSlpOnsetDiaryValue.Text = duration2str(app.ACT.stats.average.(select).avWakeAfterSlpOnsetDiary/(24*60));
app.AvStats_FinAwakeDiaryValue.Text = app.ACT.stats.average.(select).avClockFinAwakeDiary;
app.AvStats_LightsOnDiaryValue.Text = app.ACT.stats.average.(select).avClockLightsOnDiary;
app.AvStats_SlpWindowDiaryValue.Text = duration2str(app.ACT.stats.average.(select).avSlpWindowDiary/(24*60));
app.AvStats_SlpPeriodDiaryValue.Text = duration2str(app.ACT.stats.average.(select).avSlpPeriodDiary/(24*60));
app.AvStats_SlpTimeDiaryValue.Text = duration2str(app.ACT.stats.average.(select).avTotSlpTimeDiary/(24*60));
if ~isnan(app.ACT.stats.average.(select).avSlpEffSlpPeriodDiary)
    app.AvStats_SlpEffSlpPeriodDiaryValue.Text = sprintf('%.0f%%', app.ACT.stats.average.(select).avSlpEffSlpPeriodDiary);
else
    app.AvStats_SlpEffSlpPeriodDiaryValue.Text = '-';
end
if ~isnan(app.ACT.stats.average.(select).avSlpEffSlpTimeDiary)
    app.AvStats_SlpEffSlpTimeDiaryValue.Text = sprintf('%.0f%%', app.ACT.stats.average.(select).avSlpEffSlpTimeDiary);
else
    app.AvStats_SlpEffSlpTimeDiaryValue.Text = '-';
end

% ---------------------------------------------------------
% Set Text values of the Sleep Period Mismatch
mismatch = app.ACT.stats.average.(select).avSleepPeriodMismatch;
if mismatch > 0
    mismatch = sprintf('%s', duration2str(abs(mismatch)/(24*60)));
elseif mismatch < 0
    mismatch = sprintf('-%s', duration2str(abs(mismatch)/(24*60)));
elseif ~isnan(app.ACT.stats.average.(select).avSlpPeriodAct) && ~isnan(app.ACT.stats.average.(select).avSlpPeriodDiary)
    mismatch = 'no mismatch';
else
    mismatch = '-';
end
app.AvStats_MismatchSleepPeriodValue.Text = mismatch;

% ---------------------------------------------------------
% Set Text values of the Sleep Time Mismatch
mismatch = app.ACT.stats.average.(select).avSleepTimeMismatch;
if mismatch > 0
    mismatch = sprintf('%s', duration2str(abs(mismatch)/(24*60)));
elseif mismatch < 0
    mismatch = sprintf('-%s', duration2str(abs(mismatch)/(24*60)));
elseif ~isnan(app.ACT.stats.average.(select).avTotSlpTimeAct) && ~isnan(app.ACT.stats.average.(select).avTotSlpTimeDiary)
    mismatch = 'no mismatch';
else
    mismatch = '-';
end
app.AvStats_MismatchSleepTimeValue.Text = mismatch;

end
