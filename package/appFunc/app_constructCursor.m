function app_constructCursor(app)
% ---------------------------------------------------------
% If the position field of the cursor is not set, then there is no cursor to plot, so return
if ~isfield(app.Cursor, 'Position')
    return
end
% ---------------------------------------------------------
% Only go ahead if 'Cursor' is listed in the component list
if ~ismember('Cursor', app.ComponentList)
    return
end

% ---------------------------------------------------------
% Check if the user clicked on an axis in the data tab, or in the stats tab
switch class(app.Cursor.Parent)
    case 'matlab.ui.container.Panel'
        % We're in the data analysis tab, so do the following
        % ---------------------------------------------------------
        % We will plot the cursor in the axes of Events and Acceleration
        axesTypes = [{'events'}; {'acceleration'}];
        for ai = 1:length(axesTypes)
            % ---------------------------------------------------------
            % (1) THE LINE OF THE CURSOR
            % ---------------------------------------------------------
            % Check if component should mount, otherwise return the component itself
            [mount, Component] = shouldComponentMount(app, app.DataContainer, ['Cursor_', axesTypes{ai}]);
            % -----
            % Extract parent panel object to use for its children
            ax = findobj(app.Cursor.Parent.Children, 'Tag', ['Axis_day-', num2str(app.Cursor.Parent.UserData.Day), '_type-', axesTypes{ai}]);
            % ---------------------------------------------------------
            % If mount: the component is not mounted yet, go ahead and mount it
            if mount
                % Define the properties
                props = { ...
                    'Tag',           ['Cursor_', axesTypes{ai}]; ...
                    'XData',         [app.Cursor.Position, app.Cursor.Position]; ...
                    'YData',         app_getCursorYData(app, axesTypes{ai}); ...
                    'LineStyle',     '-'; ...
                    'LineWidth',     2; ...
                    'Marker',        'none'; ...
                    'Color',         [0.8039, 0.2431, 0.5765]; ...
                    };
                % Mount component using the 'mount_plot' function
                mountComponent(app, 'mount_plot', ax, props);
                % ---------------------------------------------------------
                % Else: the component is already mounted, so merely construct it
            else
                % Construct the component with its updated XData and Parent
                constructComponent(app, Component, Component.Parent, { ...
                    'XData', [app.Cursor.Position, app.Cursor.Position]; ...
                    'Parent', ax; ...
                    });
            end
            % ---------------------------------------------------------
            % (2) THE LABEL OF THE CURSOR (HH:MM)
            if ai == 1 % if we're in the 'events' axes
                % ---------------------------------------------------------
                % Check if component should mount, otherwise return the component itself
                [mount, Component] = shouldComponentMount(app, app.DataContainer, 'CursorLabel');
                % ---------------------------------------------------------
                % If mount: the component is not mounted yet, go ahead and mount it
                if mount
                    % Define the properties
                    props = { ...
                        'Tag', 'CursorLabel'; ...
                        'FontSize', 8; ...
                        'Color', 'w'; ...
                        'Parent', ax; ...
                        'VerticalAlignment', 'bottom'; ...
                        'HorizontalAlignment', ifelse(app.Cursor.Position < mean(ax.XLim), 'left', 'right'); ...
                        'BackgroundColor', [0.8039, 0.2431, 0.5765]; ...
                        'String', datestr(app.Cursor.Position, 'HH:MM'); ...
                        'Position', [app.Cursor.Position, 0.05, 0]; ...
                        'Margin', 1; ...
                        };
                    % Mount component using the 'mount_text' function
                    mountComponent(app, 'mount_text', ax, props);
                    % ---------------------------------------------------------
                    % Else: the component is already mounted, so merely construct it
                else
                    % Construct the component with its updated XData and Parent
                    constructComponent(app, Component, Component.Parent, { ...
                        'String', datestr(app.Cursor.Position, 'HH:MM'); ...
                        'HorizontalAlignment', ifelse(app.Cursor.Position < mean(ax.XLim), 'left', 'right'); ...
                        'Position', [app.Cursor.Position, 0.05, 0]; ...
                        'Parent', ax; ...
                        });
                end
            end
        end
        % ---------------------------------------------------------
    case 'matlab.ui.container.GridLayout' % We're in the daily stats tab, so do the following
        % Update the UserData of the 'DailyStats_PatchCurrentSelection' Component
        Component = findobj(app.GridLayoutDailyStats_Container.Children, 'Tag', 'DailyStats_PatchCurrentSelection');
        Component.UserData.select = min([ceil(app.Cursor.CurrentPoint(1, 2)), size(app.ACT.stats.daily, 1)]);
        app.Cursor.CurrentPoint(1, 2)
        % Add 'Stats' to the Component list
        app.ComponentList = [app.ComponentList, {'Stats'}];
end

end % EOF
