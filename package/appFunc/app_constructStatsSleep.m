function app_constructStatsSleep(app)

% Construct the Tab
Tab = app_constructTab(app, 'Tab_CicSleep', 'Sleep Stats');
GridLayoutContainer = findobj(Tab.Children, 'Tag', 'TabGridLayoutContainerPanel');
GridLayoutContainer.RowHeight = {200, '1x'};

% ---------------------------------------------------------
% Sleep overview
% ---------------------------------------------------------
% UIAxes
% -----
if shouldComponentMount(app, GridLayoutContainer, 'SleepStats_UIAxesOverview')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = [1, 12];
    % Define the properties
    props = { ...
        'Tag', 'SleepStats_UIAxesOverview'; ...
        'XLim', [0.5, max([size(app.ACT.stats.sleep.actigraphy, 1), 14])+0.5]; ...
        'XTick', 1:size(app.ACT.stats.sleep.actigraphy, 1); ...
        'YDir', 'reverse'; ...
        'YGrid', 'on'; ...
        'GridAlpha', 0.33; ...
        'YLim', [mod(datenum(app.ACT.display.actogramStartClock, 'HH:MM'), 1)*24, mod(datenum(app.ACT.display.actogramEndClock, 'HH:MM'), 1)*24+24]; ...
        'YTick', 0:1:48; ...
        'YTickLabel', datestr(0:1/24:2, 'HH:MM'); ...
        'BackgroundColor', [0.95, 0.95, 0.95]; ...
        'Layout', Layout; ...
        'Layer', 'top'; ...
        'FontSize', 10; ...
        'Box', 'on'; ...
        'NextPlot', 'add'; ...
        };
    % Mount component using the 'mount_uiaxes' function
    parent = mountComponent(app, 'mount_uiaxes', GridLayoutContainer, props);
else
    % Construct the component with its updated XLim and XTick
    parent = constructComponent(app, 'SleepStats_UIAxesOverview', GridLayoutContainer, { ...
        'XLim', [0.5, max([size(app.ACT.stats.sleep.actigraphy, 1), 14])+0.5]; ...
        'XTick', 1:size(app.ACT.stats.sleep.actigraphy, 1); ...
        });
end
% -----
% Update parent axes object's YLim directly, so we can adjust it's value at the end of the next for loop
parent.YLim = [mod(datenum(app.ACT.display.actogramStartClock, 'HH:MM'), 1)*24, mod(datenum(app.ACT.display.actogramEndClock, 'HH:MM'), 1)*24+24];
% -----
% For each sleepwindow ...
for si = 1:size(app.ACT.stats.sleep.actigraphy, 1)
    % -----
    % Patch Sleep Window
    % -----
    % Extract YData
    y    = mod(datenum(app.ACT.stats.sleep.actigraphy.clockLightsOut{si}, 'dd/mm/yyyy HH:MM'), 1)*24;
    y    = ifelse(y < parent.YLim(1), y+24, y);
    y(2) = mod(datenum(app.ACT.stats.sleep.actigraphy.clockLightsOn{si}, 'dd/mm/yyyy HH:MM'), 1)*24;
    while y(2) < y(1); y(2) = y(2) + 24; end
    % -----
    % Check if YLim should be updated
    if si == 1
        YLim = y;
    else
        if YLim(1) > y(1); YLim(1) = y(1); end
        if YLim(2) < y(2); YLim(2) = y(2); end
    end
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['SleepStats_PatchOverview_sleepWindow-', num2str(si)])
        % Define the properties
        props = {...
            'Tag', ['SleepStats_PatchOverview_sleepWindow-', num2str(si)]; ...
            'XData', [si-0.25, si-0.25, si+0.25, si+0.25]; ...
            'YData', [y, fliplr(y)]; ...
            'FaceColor', app.SleepWindowButton.BackgroundColor; ...
            'LineStyle', 'none'; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_patch', parent, props);
    else
        % Construct the component with its updated X, Y and CData
        constructComponent(app, ['SleepStats_PatchOverview_sleepWindow-', num2str(si)], parent, {...
            'XData', [si-0.25, si-0.25, si+0.25, si+0.25]; ...
            'YData', [y, fliplr(y)]; ...
            });
    end
    % -----
    % Patch Sleep Period
    % -----
    % If there is no sleep period this day, continue to the next day
    if strcmpi(app.ACT.stats.sleep.actigraphy.clockSlpOnset{si}, 'na')
        continue
    end
    % Extract YData
    y    = mod(datenum(app.ACT.stats.sleep.actigraphy.clockSlpOnset{si}, 'dd/mm/yyyy HH:MM'), 1)*24;
    y    = ifelse(y < parent.YLim(1), y+24, y);
    y(2) = mod(datenum(app.ACT.stats.sleep.actigraphy.clockFinAwake{si}, 'dd/mm/yyyy HH:MM'), 1)*24;
    while y(2) < y(1); y(2) = y(2) + 24; end
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['SleepStats_PatchOverview_sleepPeriod-', num2str(si)])
        % Define the properties
        props = {...
            'Tag', ['SleepStats_PatchOverview_sleepPeriod-', num2str(si)]; ...
            'XData', [si-0.25, si-0.25, si+0.25, si+0.25]; ...
            'YData', [y, fliplr(y)]; ...
            'FaceColor', app.SleepPeriodButton.BackgroundColor; ...
            'LineStyle', 'none'; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_patch', parent, props);
    else
        % Construct the component with its updated X, Y and CData
        constructComponent(app, ['SleepStats_PatchOverview_sleepPeriod-', num2str(si)], parent, {...
            'XData', [si-0.25, si-0.25, si+0.25, si+0.25]; ...
            'YData', [y, fliplr(y)]; ...
            });
    end
    % -----
    % Patch Awakening
    % -----
    % Extract YData
    events = selectEventsUsingTime(app.ACT.analysis.events, ...
        datenum(app.ACT.stats.sleep.actigraphy.clockSlpOnset{si}, 'dd/mm/yyyy HH:MM'), ...
        datenum(app.ACT.stats.sleep.actigraphy.clockFinAwake{si}, 'dd/mm/yyyy HH:MM'), ...
        'Label', 'waso', ...
        'Type', 'actigraphy');
    if isempty(events)
        continue
    end
    YData = mod(reshape([events.onset, events.onset, events.onset+events.duration, events.onset+events.duration]', 1, 4*size(events, 1)), 1) * 24;
    YData = ifelse(YData(1) < parent.YLim(1), YData+24, YData);
    idxAdd = find(YData(2:end) < YData(1:end-1), 1, 'first');
    if ~isempty(idxAdd); YData(idxAdd+1:end) = YData(idxAdd+1:end)+24; end
    XData = repmat([si-0.25, si+0.25, si+0.25, si-0.25], 1, size(events, 1));
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['SleepStats_PatchOverview_awakening-', num2str(si)])
        % Define the properties
        props = {...
            'Tag', ['SleepStats_PatchOverview_awakening-', num2str(si)]; ...
            'XData', XData; ...
            'YData', YData; ...
            'FaceColor', [0.3686, 0.5725, 0.9529]; ...
            'LineStyle', 'none'; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_patch', parent, props);
    else
        % Construct the component with its updated X, Y and CData
        constructComponent(app, ['SleepStats_PatchOverview_awakening-', num2str(si)], parent, {...
            'XData', XData; ...
            'YData', YData; ...
            });
    end
end
% Update the parent axes' YLim
parent.YLim = YLim + [-0.5, 0.5];

% ---------------------------------------------------------
% Individual sleep panels
% ---------------------------------------------------------
% UIPanel to function as a container
% -----
% Check if component should mount
if shouldComponentMount(app, GridLayoutContainer, 'SleepStats_ContainerPanel')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 2;
    Layout.Column = [1, 12];
    % Define the properties
    props = {...
        'Tag', 'SleepStats_ContainerPanel'; ...
        'Title', ''; ...
        'Layout', Layout; ...
        'BorderType', 'none'; ...
        'BackgroundColor', [0.94, 0.94, 0.94]; ...
        };
    % Mount component using the 'mount_uipanel' function
    mountComponent(app, 'mount_uipanel', GridLayoutContainer, props);
end
% -----
% Extract parent panel object to use for its children
parent = findobj(GridLayoutContainer.Children, 'Tag', 'SleepStats_ContainerPanel');
% -----
% UIGridLayout to house all the panels
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'SleepStats_GridLayoutContainerPanel')
    % Define the properties
    props = {...
        'Tag', 'SleepStats_GridLayoutContainerPanel'; ...
        'ColumnWidth', {'1x'}; ...
        'RowHeight', repmat({120}, 1, size(app.ACT.stats.sleep.actigraphy, 1)); ...
        'ColumnSpacing', 0; ...
        'RowSpacing', 3; ...
        'Padding', [0, 0, 0, 0]; ...
        'Scrollable', 'on'; ...
        };
    % Mount component using the 'mount_uigridlayout' function
    mountComponent(app, 'mount_uigridlayout', parent, props);
end
% -----
% Extract parent gridlayout object to use for its children
SleepStats_GridLayoutContainerPanel = findobj(GridLayoutContainer.Children, 'Tag', 'SleepStats_GridLayoutContainerPanel');
% -----
% For each sleepwindow ...
for si = 1:size(app.ACT.stats.sleep.actigraphy, 1)
    % -----
    % UIPanel
    % -----
    % Check if component should mount
    if shouldComponentMount(app, SleepStats_GridLayoutContainerPanel, ['SleepStats_Panel-', num2str(si)])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = si;
        Layout.Column = 1;
        % Define the properties
        props = {...
            'Tag', ['SleepStats_Panel-', num2str(si)]; ...
            'Title', ['Sleep Window #', num2str(si)]; ...
            'FontSize', 8; ...
            'FontWeight', 'bold'; ...
            'Layout', Layout; ...
            'BackgroundColor', [1, 1, 1]; ...
            };
        % Mount component using the 'mount_uipanel' function
        mountComponent(app, 'mount_uipanel', SleepStats_GridLayoutContainerPanel, props);
    end
    % -----
    % Extract parent panel object to use for its children
    parent = findobj(SleepStats_GridLayoutContainerPanel.Children, 'Tag', ['SleepStats_Panel-', num2str(si)]);
    % -----
    % UIGridLayout
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['SleepStats_GridLayout-', num2str(si)])
        % Define the properties
        props = {...
            'Tag', ['SleepStats_GridLayout-', num2str(si)]; ...
            'ColumnWidth', [{100}, {35}, repmat({'1x'}, 1, size(app.ACT.stats.sleep.actigraphy, 2)-2)]; ...
            'RowHeight', {'1x', 28, 28, 28, 28, '1x'}; ...
            'ColumnSpacing', 0; ...
            'RowSpacing', 0; ...
            'Padding', [0, 0, 0, 0]; ...
            };
        % Mount component using the 'mount_uigridlayout' function
        mountComponent(app, 'mount_uigridlayout', parent, props);
    end
    % -----
    % Extract parent panel object to use for its children
    parent = findobj(parent.Children, 'Tag', ['SleepStats_GridLayout-', num2str(si)]);
    % -----
    % Actigraphy label
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['SleepStats_ActLabel_Panel-', num2str(si)])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = 3;
        Layout.Column = 2;
        % Define the properties
        props = {...
            'Tag', ['SleepStats_ActLabel_Panel-', num2str(si)]; ...
            'Layout', Layout; ...
            'FontSize', 12; ...
            'FontColor', [0, 0.2392, 0.5608]; ...
            'FontWeight', 'bold'; ...
            'HorizontalAlignment', 'right'; ...
            'Text', 'Act'; ...
            };
        % Mount component using the 'mount_patch' function
        mountComponent(app, 'mount_uilabel', parent, props);
    end
    % -----
    % Sleep Diary label and find the corresponding night
    % -----
    if isfield(app.ACT.stats.sleep, 'sleepDiary')
        % Find the index of this night in the sleep diary table
        onset  = datenum(app.ACT.stats.sleep.sleepDiary.clockLightsOut, 'dd/mm/yyyy HH:MM');
        offset = datenum(app.ACT.stats.sleep.sleepDiary.clockLightsOn, 'dd/mm/yyyy HH:MM');
        idx = ...
            (...
            onset >= datenum(app.ACT.stats.sleep.actigraphy.clockLightsOut{si}, 'dd/mm/yyyy HH:MM') & ...
            onset <= datenum(app.ACT.stats.sleep.actigraphy.clockLightsOn{si}, 'dd/mm/yyyy HH:MM') ...
            ) | (...
            offset >= datenum(app.ACT.stats.sleep.actigraphy.clockLightsOut{si}, 'dd/mm/yyyy HH:MM') & ...
            offset <= datenum(app.ACT.stats.sleep.actigraphy.clockLightsOn{si}, 'dd/mm/yyyy HH:MM') ...
            ) | (...
            onset <= datenum(app.ACT.stats.sleep.actigraphy.clockLightsOut{si}, 'dd/mm/yyyy HH:MM') & ...
            offset >= datenum(app.ACT.stats.sleep.actigraphy.clockLightsOn{si}, 'dd/mm/yyyy HH:MM') ...
            );
        if sum(idx) == 1 % if exactly one night is found, go ahead
            % Check if component should mount
            if shouldComponentMount(app, parent, ['SleepStats_DiaryLabel_Panel-', num2str(si)])
                % Set Layout
                Layout = app.DataPanel.Layout;
                Layout.Row = 4;
                Layout.Column = 2;
                % Define the properties
                props = {...
                    'Tag', ['SleepStats_DiaryLabel_Panel-', num2str(si)]; ...
                    'Layout', Layout; ...
                    'FontSize', 12; ...
                    'FontColor', [0, 0.3412, 0.3804]; ...
                    'FontWeight', 'bold'; ...
                    'HorizontalAlignment', 'right'; ...
                    'Text', 'Diary'; ...
                    };
                % Mount component using the 'mount_patch' function
                mountComponent(app, 'mount_uilabel', parent, props);
            end
        else
            idx = false;
            unmountComponent(app, findobj(parent.Children, '-regexp', 'Tag', ['SleepStats_Diary.+_Panel-', num2str(si)]));
        end
    else
        idx = false;
        unmountComponent(app, findobj(parent.Children, '-regexp', 'Tag', ['SleepStats_Diary.+_Panel-', num2str(si)]));
    end
    % -----
    % Actigraphy Labels and values
    % -----
    fnames = app.ACT.stats.sleep.actigraphy.Properties.VariableNames;
    for fi = 3:length(fnames)
        % -----
        % Define custom label
        switch fnames{fi}
            case 'day'
                Label = 'Day';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi}){si};
                if sum(idx) == 1; DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi}){idx}; else; DiaryValue = ''; end
            case 'clockLightsOut'
                Label = 'Lights Out';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi}){si}(end-4:end);
                if sum(idx) == 1; DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi}){idx}(end-4:end); else; DiaryValue = ''; end
            case 'clockLightsOn'
                Label = 'Lights On';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi}){si}(end-4:end);
                if sum(idx) == 1; DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi}){idx}(end-4:end); else; DiaryValue = ''; end
            case 'clockSlpOnset'
                Label = 'Slp Onset';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi}){si};
                if strcmpi(ActValue, 'na'); ActValue = '-'; else; ActValue = convertDatestr(ActValue, 'dd/mm/yyyy HH:MM', 'HH:MM'); end
                if sum(idx) == 1
                    DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi}){idx};
                    if strcmpi(DiaryValue, 'na'); DiaryValue = '-'; else; DiaryValue = convertDatestr(DiaryValue, 'dd/mm/yyyy HH:MM', 'HH:MM'); end
                else
                    DiaryValue = ''; 
                end
            case 'clockFinAwake'
                Label = 'FA';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi}){si};
                if strcmpi(ActValue, 'na'); ActValue = '-'; else; ActValue = convertDatestr(ActValue, 'dd/mm/yyyy HH:MM', 'HH:MM'); end
                if sum(idx) == 1
                    DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi}){idx};
                    if strcmpi(DiaryValue, 'na'); DiaryValue = '-'; else; DiaryValue = convertDatestr(DiaryValue, 'dd/mm/yyyy HH:MM', 'HH:MM'); end
                else
                    DiaryValue = ''; 
                end
            case 'slpOnsetLat'
                Label = 'SOL';
                ActValue = duration2str(app.ACT.stats.sleep.actigraphy.(fnames{fi})(si)/(24*60));
                if sum(idx) == 1; DiaryValue = duration2str(app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx)/(24*60)); else; DiaryValue = ''; end
            case 'nAwakening'
                Label = 'Awakening';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi})(si);
                ActValue = ifelse(isnan(ActValue), '-', sprintf('%ix', ActValue));
                if sum(idx) == 1
                    DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx);
                    DiaryValue = ifelse(isnan(DiaryValue), '-', sprintf('%ix', DiaryValue));
                else
                    DiaryValue = ''; 
                end
            case 'wakeAfterSlpOnset'
                Label = 'WASO';
                ActValue = duration2str(app.ACT.stats.sleep.actigraphy.(fnames{fi})(si)/(24*60));
                if sum(idx) == 1; DiaryValue = duration2str(app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx)/(24*60)); else; DiaryValue = '-'; end
            case 'totSlpTime'
                Label = 'Slp Time';
                ActValue = duration2str(app.ACT.stats.sleep.actigraphy.(fnames{fi})(si)/(24*60));
                if sum(idx) == 1; DiaryValue = duration2str(app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx)/(24*60)); else; DiaryValue = '-'; end
            case 'slpPeriod'
                Label = 'Slp Period';
                ActValue = duration2str(app.ACT.stats.sleep.actigraphy.(fnames{fi})(si)/(24*60));
                if sum(idx) == 1; DiaryValue = duration2str(app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx)/(24*60)); else; DiaryValue = '-'; end
            case 'slpWindow'
                Label = 'Sleep Win';
                ActValue = duration2str(app.ACT.stats.sleep.actigraphy.(fnames{fi})(si)/(24*60));
                if sum(idx) == 1; DiaryValue = duration2str(app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx)/(24*60)); else; DiaryValue = '-'; end
            case 'slpEffSlpTime'
                Label = 'SE_TST';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi})(si);
                ActValue = ifelse(isnan(ActValue), '-', sprintf('%.1f%%', ActValue));
                if sum(idx) == 1
                    DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx);
                    DiaryValue = ifelse(isnan(DiaryValue), '-', sprintf('%.1f%%', DiaryValue));
                else
                    DiaryValue = '-';
                end
            case 'slpEffSlpPeriod'
                Label = 'SE_TSP';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi})(si);
                ActValue = ifelse(isnan(ActValue), '-', sprintf('%.1f%%', ActValue));
                if sum(idx) == 1
                    DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx);
                    DiaryValue = ifelse(isnan(DiaryValue), '-', sprintf('%.1f%%', DiaryValue));
                else
                    DiaryValue = '-';
                end
            case 'awakePerHour'
                Label = 'Awake/hr';
                ActValue = app.ACT.stats.sleep.actigraphy.(fnames{fi})(si);
                ActValue = ifelse(isnan(ActValue), '-', sprintf('%.2f', ActValue));
                if sum(idx) == 1
                    DiaryValue = app.ACT.stats.sleep.sleepDiary.(fnames{fi})(idx);
                    DiaryValue = ifelse(isnan(DiaryValue), '-', sprintf('%.2f', DiaryValue));
                else
                    DiaryValue = '-';
                end
        end
        % -----
        % Label
        % -----
        % Check if component should mount
        if shouldComponentMount(app, parent, ['SleepStats_ActLabel-', fnames{fi}, '_Panel-', num2str(si)])
            % Set Layout
            Layout = app.DataPanel.Layout;
            Layout.Row = 2;
            Layout.Column = fi;
            % Define the properties
            props = {...
                'Tag', ['SleepStats_ActLabel-', fnames{fi}, '_Panel-', num2str(si)]; ...
                'Layout', Layout; ...
                'FontSize', 10; ...
                'FontColor', [0.15, 0.15, 0.15]; ...
                'HorizontalAlignment', 'center'; ...
                'Text', Label; ...
                };
            % Mount component using the 'mount_patch' function
            mountComponent(app, 'mount_uilabel', parent, props);
        end
        % -----
        % Actigraphy Value
        % -----
        % Check if component should mount
        if shouldComponentMount(app, parent, ['SleepStats_ActValue-', fnames{fi}, '_Panel-', num2str(si)])
            % Set Layout
            Layout = app.DataPanel.Layout;
            Layout.Row = 3;
            Layout.Column = fi;
            % Define the properties
            props = {...
                'Tag', ['SleepStats_ActValue-', fnames{fi}, '_Panel-', num2str(si)]; ...
                'Layout', Layout; ...
                'FontSize', 12; ...
                'FontColor', [0, 0.2392, 0.5608]; ...
                'FontWeight', 'bold'; ...
                'HorizontalAlignment', 'center'; ...
                'Text', ActValue; ...
                };
            % Mount component using the 'mount_patch' function
            mountComponent(app, 'mount_uilabel', parent, props);
        else
            % Construct the component with its updated Text value
            constructComponent(app, ['SleepStats_ActValue-', fnames{fi}, '_Panel-', num2str(si)], parent, {...
                'Text', ActValue; ...
                });
        end
        % -----
        % Diary Value
        % -----
        if isfield(app.ACT.stats.sleep, 'sleepDiary') && sum(idx == 1)
            % Check if component should mount
            if shouldComponentMount(app, parent, ['SleepStats_DiaryValue-', fnames{fi}, '_Panel-', num2str(si)])
                % Set Layout
                Layout = app.DataPanel.Layout;
                Layout.Row = 4;
                Layout.Column = fi;
                % Define the properties
                props = {...
                    'Tag', ['SleepStats_DiaryValue-', fnames{fi}, '_Panel-', num2str(si)]; ...
                    'Layout', Layout; ...
                    'FontSize', 12; ...
                    'FontColor', [0, 0.3412, 0.3804]; ...
                    'FontWeight', 'bold'; ...
                    'HorizontalAlignment', 'center'; ...
                    'Text', ifelse(isempty(DiaryValue), '-', DiaryValue); ...
                    };
                % Mount component using the 'mount_patch' function
                mountComponent(app, 'mount_uilabel', parent, props);
            else
                % Construct the component with its updated Text value
                constructComponent(app, ['SleepStats_DiaryValue-', fnames{fi}, '_Panel-', num2str(si)], parent, {...
                    'Text', ifelse(isempty(DiaryValue), '-', DiaryValue); ...
                    });
            end
        end
    end
    % ---------------------------------------------------------
    % SleepClock
    % ---------------------------------------------------------
    % UIAxes
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['SleepStats_UIAxesSleepClock-', num2str(si)])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = [1, 6];
        Layout.Column = 1;
        % Define the properties
        props = { ...
            'Tag', ['SleepStats_UIAxesSleepClock-', num2str(si)]; ...
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
        mountComponent(app, 'mount_uiaxes', parent, props);
    end
    % -----
    % Extract parent axes object to use for its children
    parent = findobj(parent.Children, 'Tag', ['SleepStats_UIAxesSleepClock-', num2str(si)]);
    % -----
    % The clock as too many components to mount/construct so simply delete the clock and plot it again
    delete(parent.Children)
    % -----
    % Get the data for the sleep clock
    try
        SleepWindowAct = [datenum(app.ACT.stats.sleep.actigraphy.clockLightsOut{si}, 'dd/mm/yyyy HH:MM'), datenum(app.ACT.stats.sleep.actigraphy.clockLightsOn{si}, 'dd/mm/yyyy HH:MM')];
    catch
        SleepWindowAct = [];
    end
    try
        SleepPeriodAct = [datenum(app.ACT.stats.sleep.actigraphy.clockSlpOnset{si}, 'dd/mm/yyyy HH:MM'), datenum(app.ACT.stats.sleep.actigraphy.clockFinAwake{si}, 'dd/mm/yyyy HH:MM')];
    catch
        SleepPeriodAct = [];
    end
    try
        AwakeningAct = waso2bouts(...
            app.ACT.stats.sleep.actigraphy.wakeAfterSlpOnset(si), ...
            app.ACT.stats.sleep.actigraphy.nAwakening(si), ...
            datenum(app.ACT.stats.sleep.actigraphy.clockSlpOnset{si}, 'dd/mm/yyyy HH:MM'), ...
            datenum(app.ACT.stats.sleep.actigraphy.clockFinAwake{si}, 'dd/mm/yyyy HH:MM'));
    catch
        AwakeningAct = [];
    end
    try
        SleepWindowDiary = [datenum(app.ACT.stats.sleep.sleepDiary.clockLightsOut{idx}, 'dd/mm/yyyy HH:MM'), datenum(app.ACT.stats.sleep.sleepDiary.clockLightsOn{idx}, 'dd/mm/yyyy HH:MM')];
    catch
        SleepWindowDiary = [];
    end
    try
        SleepPeriodDiary = [datenum(app.ACT.stats.sleep.sleepDiary.clockSlpOnset{idx}, 'dd/mm/yyyy HH:MM'), datenum(app.ACT.stats.sleep.sleepDiary.clockFinAwake{idx}, 'dd/mm/yyyy HH:MM')];
    catch
        SleepPeriodDiary = [];
    end
    try
        AwakeningDiary = waso2bouts(...
            app.ACT.stats.sleep.sleepDiary.wakeAfterSlpOnset(idx), ...
            app.ACT.stats.sleep.sleepDiary.nAwakening(idx), ...
            datenum(app.ACT.stats.sleep.sleepDiary.clockSlpOnset{idx}, 'dd/mm/yyyy HH:MM'), ...
            datenum(app.ACT.stats.sleep.sleepDiary.clockFinAwake{idx}, 'dd/mm/yyyy HH:MM'));
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
end

end %EOF
