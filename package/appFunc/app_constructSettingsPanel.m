function app_constructSettingsPanel(app)

for di = 1:length(app.ACT.display.order)
    % Get how many fields are part of this data
    if isfield(app.ACT.display, app.ACT.display.order{di})
        fnames = fieldnames(app.ACT.display.(app.ACT.display.order{di}).field);
    else
        fnames = fieldnames(app.ACT.data.(app.ACT.display.order{di}));
    end
    % ---------------------------------------------------------
    % Settings panel for each data type
    % -----
    % UIGridLayout for move buttons
    % -----
    % Check if component should mount
    if shouldComponentMount(app, app.GridLayoutSettingsPanel, ['GridLayoutMove_', app.ACT.display.order{di}])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = di+2;
        Layout.Column = 3;
        % Set UserData
        UserData.datatype = app.ACT.display.order{di};
        % Define the properties
        props = { ...
            'Tag', ['GridLayoutMove_', app.ACT.display.order{di}];...
            'RowHeight', {18, 18}; ...
            'ColumnWidth', {'1x'}; ...
            'ColumnSpacing', 0; ...
            'Padding', [0, 0, 0, 0]; ...
            'Layout', Layout; ...
            'UserData', UserData; ...
            };
        % Mount component using the 'mount_uigridlayout' function
        parent = mountComponent(app, 'mount_uigridlayout', app.GridLayoutSettingsPanel, props);
    else
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = di+2;
        Layout.Column = 3;
        % Set UserData
        UserData.datatype = app.ACT.display.order{di};
        % Construct the component with its updated UserData and Tag
        parent = constructComponent(app, ['GridLayoutMove_', app.ACT.display.order{di}], app.GridLayoutSettingsPanel, { ...
            'Layout', Layout; ...
            'UserData', UserData; ...
            });
    end
    % -----
    % Move Up UIButton
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, 'MoveUpButton')
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = 1;
        Layout.Column = 1;
        % Set UserData
        UserData.input = 'order';
        UserData.type = app.ACT.display.order{di};
        UserData.direction = -1;
        % Create properties
        props = {
            'Tag', 'MoveUpButton'; ...
            'Text', '^'; ...
            'FontSize', 8; ...
            'FontWeight', 'bold'; ...
            'FontColor', [0.15, 0.15, 0.15]; ...
            'Enable', ifelse(di>1, 'on', 'off'); ...
            'Layout', Layout; ...
            'UserData', UserData; ...
            };
        % Mount component using the 'mount_uibutton' function
        mountComponent(app, 'mount_uibutton', parent, props);
    else
        % Set UserData
        UserData.input = 'order';
        UserData.type = app.ACT.display.order{di};
        UserData.direction = -1;
        % Construct the component with its updated UserData 
        constructComponent(app, 'MoveUpButton', parent, {
            'UserData', UserData; ...
            'Enable', ifelse(di>1, 'on', 'off'); ...
            });
    end
    % -----
    % Move Down UIButton
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, 'MoveDownButton')
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = 2;
        Layout.Column = 1;
        % Set UserData
        UserData.input = 'order';
        UserData.type = app.ACT.display.order{di};
        UserData.direction = 1;
        % Create properties
        props = {
            'Tag', 'MoveDownButton'; ...
            'Text', 'v'; ...
            'FontSize', 8; ...
            'FontWeight', 'bold'; ...
            'FontColor', [0.15, 0.15, 0.15]; ...
            'Enable', ifelse(di<length(app.ACT.display.order), 'on', 'off'); ...
            'Layout', Layout; ...
            'UserData', UserData; ...
            };
        % Mount component using the 'mount_uibutton' function
        mountComponent(app, 'mount_uibutton', parent, props);
    else
        % Set UserData
        UserData.input = 'order';
        UserData.type = app.ACT.display.order{di};
        UserData.direction = 1;
        % Construct the component with its updated UserData 
        constructComponent(app, 'MoveDownButton', parent, {
            'UserData', UserData; ...
            'Enable', ifelse(di<length(app.ACT.display.order), 'on', 'off'); ...
            });
    end
    % -----
    % UIPanel
    % -----
    % Check if component should mount
    if shouldComponentMount(app, app.GridLayoutSettingsPanel, ['SettingsPanel_', app.ACT.display.order{di}])
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = di + 2;
        Layout.Column = [1, 2];
        % Define the properties
        props = {...
            'Tag', ['SettingsPanel_', app.ACT.display.order{di}]; ...
            'Title', titleCase(app.ACT.display.order{di}); ...
            'Layout', Layout; ...
            'FontSize', 10; ...
            'FontWeight', 'bold'; ...
            'BackgroundColor', [0.94, 0.94, 0.94]; ...
            };
        % Mount component using the 'mount_uipanel' function
        parent = mountComponent(app, 'mount_uipanel', app.GridLayoutSettingsPanel, props);
    else
        % Set Layout
        Layout = app.DataPanel.Layout;
        Layout.Row = di + 2;
        Layout.Column = [1, 2];
        % Construct the component with its updated Tag 
        parent = constructComponent(app, ['SettingsPanel_', app.ACT.display.order{di}], app.GridLayoutSettingsPanel, {
            'Layout', Layout; ...
            });
    end
    % -----
    % UIGridLayout
    % -----
    % Check if component should mount
    if shouldComponentMount(app, parent, ['GridLayoutSettingsPanel_', app.ACT.display.order{di}])
        % Define the properties
        props = {...
            'Tag', ['GridLayoutSettingsPanel_', app.ACT.display.order{di}]; ...
            'ColumnWidth', {55, '1x', '1x'}; ...
            'RowHeight', {18, 18, 18, 21*length(fnames)+3}; ...
            'ColumnSpacing', 3; ...
            'RowSpacing', 3; ...
            'Padding', [3, 3, 3, 3]; ...
            };
        % Mount component using the 'mount_uigridlayout' function
        mountComponent(app, 'mount_uigridlayout', parent, props);
    else
        % Construct the component with its updated Row Height 
        constructComponent(app, ['GridLayoutSettingsPanel_', app.ACT.display.order{di}], parent, { ...
            'RowHeight', {18, 18, 18, 21*length(fnames)+3}; ...
            });
    end
    % -----
    % Extract parent gridlayout object to use for its children
    parent = findobj(parent.Children, 'Tag', ['GridLayoutSettingsPanel_', app.ACT.display.order{di}]);
    % -----
    % The Labels and Input Fields for this Panel
    % -----
    app_constructSettingsPanelInput(app, parent, app.ACT.display.order{di}, fnames);
end

% ---------------------------------------------------------
% Settings panel for Annotation Type
% ---------------------------------------------------------
% UIPanel
% -----
% Check if component should mount
if shouldComponentMount(app, app.GridLayoutSettingsPanel, 'AnnotationTypePanel')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = length(app.ACT.display.order)+3;
    Layout.Column = [1, 2];
    % Define the properties
    props = { ...
        'Tag', 'AnnotationTypePanel'; ...
        'Visible', ifelse(isempty(fieldnames(app.ACT.analysis.annotate)), 'off', 'on'); ...
        'Layout',  Layout; ...
        'Title', 'Annotation Type'; ...
        'FontSize', 10; ...
        'FontWeight', 'bold'; ...
        'BackgroundColor', [0.94, 0.94, 0.94]; ...
        };
    % Mount component using the 'mount_uipanel' function
    parent = mountComponent(app, 'mount_uipanel', app.GridLayoutSettingsPanel, props);
else
    % Construct the component with its updated Tag 
    parent = constructComponent(app, 'AnnotationTypePanel', app.GridLayoutSettingsPanel, { ...
        'Visible', ifelse(isempty(fieldnames(app.ACT.analysis.annotate)), 'off', 'on'); ...
        });
end
% -----
% UIGridLayout
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'GridLayoutAnnotationTypePanel')
    % Define the properties
    props = {...
        'Tag', 'GridLayoutAnnotationTypePanel'; ...
        'ColumnWidth', {'1x', 22}; ...
        'RowHeight', {22}; ...
        'ColumnSpacing', 3; ...
        'RowSpacing', 3; ...
        'Padding', [3, 3, 3, 3]; ...
        };
    % Mount component using the 'mount_uigridlayout' function
    mountComponent(app, 'mount_uigridlayout', parent, props);
end
% -----
% Extract parent gridlayout object to use for its children
parent = findobj(parent.Children, 'Tag', 'GridLayoutAnnotationTypePanel');
% -----
% UIDropdown
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'AnnotationTypeInput')
    % Set Items
    Items = fieldnames(app.ACT.analysis.annotate);
    Items = ifelse(isempty(Items), {'Select...'}, Items);
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = 1;
    % Set UserData
	UserData.type = 'na';
	UserData.input = 'na';
    % Define the properties
    props = {
        'Tag', 'AnnotationTypeInput'; ...
        'FontSize', 10; ...
        'Items', Items; ...
        'Value', Items{1}; ...
        'Layout', Layout; ...
        'UserData', UserData; ...
        };
    % Mount component using the 'mount_uidropdown' function
    mountComponent(app, 'mount_uidropdown', parent, props);
else
    % Get Items
    Items = fieldnames(app.ACT.analysis.annotate);
    % Construct the component with its updated Items
    constructComponent(app, 'AnnotationTypeInput', parent, {
        'Items', Items; ...
        });
end
% -----
% Delete UIButton
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'AnnotationTypeDeleteButton')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = 2;
    % Set UserData
    UserData.input = 'deleteAnnotation';
    UserData.type = 'annotation';
    % Create properties
    props = {
        'Tag', 'AnnotationTypeDeleteButton'; ...
        'Text', ''; ...
        'Icon', 'iconTrash.png'; ...
        'BackgroundColor', [0.90, 0.18, 0.18]; ...
        'Layout', Layout; ...
        'UserData', UserData; ...
        };
    % Mount component using the 'mount_uibutton' function
    mountComponent(app, 'mount_uibutton', parent, props);
end

% ---------------------------------------------------------
% Settings panel for Sleep Window Type
% ---------------------------------------------------------
% UIPanel
% -----
% Check if component should mount
if shouldComponentMount(app, app.GridLayoutSettingsPanel, 'SleepWindowTypePanel')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = length(app.ACT.display.order)+4;
    Layout.Column = [1, 2];
    % Define the properties
    props = { ...
        'Tag', 'SleepWindowTypePanel'; ...
        'Visible', ifelse(any(ismember(app.ACT.analysis.events.label, {'sleepWindow', 'napWindow'})), 'on', 'off'); ...
        'Layout',  Layout; ...
        'Title', 'Sleep Window Type'; ...
        'FontSize', 10; ...
        'FontWeight', 'bold'; ...
        'BackgroundColor', [0.94, 0.94, 0.94]; ...
        };
    % Mount component using the 'mount_uipanel' function
    parent = mountComponent(app, 'mount_uipanel', app.GridLayoutSettingsPanel, props);
else
    % Construct the component with its updated Visibility 
    parent = constructComponent(app, 'SleepWindowTypePanel', app.GridLayoutSettingsPanel, { ...
        'Visible', ifelse(any(ismember(app.ACT.analysis.events.label, {'sleepWindow', 'napWindow'})), 'on', 'off'); ...
        });
end
% -----
% UIGridLayout
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'GridLayoutSleepWindowTypePanel')
    % Define the properties
    props = {...
        'Tag', 'GridLayoutSleepWindowTypePanel'; ...
        'ColumnWidth', {'1x', 22, 22}; ...
        'RowHeight', {22}; ...
        'ColumnSpacing', 3; ...
        'RowSpacing', 3; ...
        'Padding', [3, 3, 3, 3]; ...
        };
    % Mount component using the 'mount_uigridlayout' function
    mountComponent(app, 'mount_uigridlayout', parent, props);
end
% -----
% Extract parent gridlayout object to use for its children
parent = findobj(parent.Children, 'Tag', 'GridLayoutSleepWindowTypePanel');
% -----
% UIDropdown
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'SleepWindowTypeInput')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = 1;
    % Set items
    Items = unique(app.ACT.analysis.events.type(ismember(app.ACT.analysis.events.label, {'sleepWindow', 'napWindow'})));
    if ~ismember('manual', Items)
        Items = [Items; {'manual'}];
    end
    % Set Value
    if isfield(app.ACT.analysis.settings, 'sleepWindowType')
        Items = unique([Items; {app.ACT.analysis.settings.sleepWindowType}]);
        Value = app.ACT.analysis.settings.sleepWindowType;
    else
        Value = Items{1};
    end
    % Set UserData
    UserData.type = 'na';
	UserData.input = 'sleepWindowType';
    % Create props
    props = {
        'Tag', 'SleepWindowTypeInput'; ...
        'FontSize', 10; ...
        'Items', Items; ...
        'Value', Value; ...
        'Layout', Layout; ...
        'UserData', UserData; ...
        };
    % Mount component using the 'mount_uidropdown' function
    mountComponent(app, 'mount_uidropdown', parent, props);
else
    % Set items
    Items = unique(app.ACT.analysis.events.type(ismember(app.ACT.analysis.events.label, {'sleepWindow', 'napWindow'})));
    if ~ismember('manual', Items)
        Items = [Items; {'manual'}];
    end
    % Set Value
    if isfield(app.ACT.analysis.settings, 'sleepWindowType')
        Items = unique([Items; {app.ACT.analysis.settings.sleepWindowType}]);
        Value = app.ACT.analysis.settings.sleepWindowType;
    else
        Value = Items{1};
    end
    % Construct the component with its updated Items and Value 
    constructComponent(app, 'SleepWindowTypeInput', parent, {
        'Items', Items; ...
        'Value', Value; ...
        });
end
% -----
% To-Manual UIButton
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'SleepWindowTypeToManualButton')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = 2;
    % Set UserData
    UserData.input = 'sleepWindowsToManual';
    UserData.type = 'sleepWindow';
    % Create properties
    props = {
        'Tag', 'SleepWindowTypeToManualButton'; ...
        'Text', ''; ...
        'Icon', 'iconEdit.png'; ...
        'BackgroundColor', [0.42, 0.46, 0.49]; ...
        'Layout', Layout; ...
        'UserData', UserData; ...
        };
    % Mount component using the 'mount_uibutton' function
    mountComponent(app, 'mount_uibutton', parent, props);
end
% -----
% Delete UIButton
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'SleepWindowTypeDeleteButton')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = 3;
    % Set UserData
    UserData.input = 'deleteSleepWindows';
    UserData.type = 'sleepWindow';
    % Create properties
    props = {
        'Tag', 'SleepWindowTypeDeleteButton'; ...
        'Text', ''; ...
        'Icon', 'iconTrash.png'; ...
        'BackgroundColor', [0.90, 0.18, 0.18]; ...
        'Layout', Layout; ...
        'UserData', UserData; ...
        };
    % Mount component using the 'mount_uibutton' function
    mountComponent(app, 'mount_uibutton', parent, props);
end

% ---------------------------------------------------------
% Settings panel to Delete groups of events
% ---------------------------------------------------------
% UIPanel
% -----
% Check if component should mount
if shouldComponentMount(app, app.GridLayoutSettingsPanel, 'DeleteEventsPanel')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = length(app.ACT.display.order)+5;
    Layout.Column = [1, 2];
    % Define the properties
    props = { ...
        'Tag', 'DeleteEventsPanel'; ...
        'Visible', ifelse(any(strcmpi(app.ACT.analysis.events.type, 'customEvent')), 'on', ifelse(any(strcmpi(app.ACT.analysis.events.label, 'reject')), 'on', 'off')); ...
        'Layout',  Layout; ...
        'Title', 'Delete Multiple Events'; ...
        'FontSize', 10; ...
        'FontWeight', 'bold'; ...
        'BackgroundColor', [0.94, 0.94, 0.94]; ...
        };
    % Mount component using the 'mount_uipanel' function
    parent = mountComponent(app, 'mount_uipanel', app.GridLayoutSettingsPanel, props);
else
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = length(app.ACT.display.order)+5;
    Layout.Column = [1, 2];
    % Construct the component with its updated Tag 
    parent = constructComponent(app, 'DeleteEventsPanel', app.GridLayoutSettingsPanel, { ...
        'Layout',  Layout; ...
        'Visible', ifelse(any(strcmpi(app.ACT.analysis.events.type, 'customEvent')), 'on', ifelse(any(strcmpi(app.ACT.analysis.events.label, 'reject')), 'on', 'off')); ...
        });
end
% -----
% UIGridLayout
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'GridLayoutDeleteEventsPanel')
    % Define the properties
    props = {...
        'Tag', 'GridLayoutDeleteEventsPanel'; ...
        'ColumnWidth', {'1x', 22}; ...
        'RowHeight', {22}; ...
        'ColumnSpacing', 3; ...
        'RowSpacing', 3; ...
        'Padding', [3, 3, 3, 3]; ...
        };
    % Mount component using the 'mount_uigridlayout' function
    mountComponent(app, 'mount_uigridlayout', parent, props);
end
% -----
% Extract parent gridlayout object to use for its children
parent = findobj(parent.Children, 'Tag', 'GridLayoutDeleteEventsPanel');
% -----
% UIDropdown
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'DeleteEventsInput')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = 1;
    % Set UserData
	UserData.type = 'na';
	UserData.input = 'na';
    % Set Items
    Items = [{'Select...'}; unique(app.ACT.analysis.events.label(strcmpi(app.ACT.analysis.events.type, 'customEvent') | strcmpi(app.ACT.analysis.events.label, 'reject')))];
    % Define the properties
    props = {
        'Tag', 'DeleteEventsInput'; ...
        'FontSize', 10; ...
        'Items', Items; ...
        'Value', 'Select...'; ...
        'Layout', Layout; ...
        'UserData', UserData; ...
        };
    % Mount component using the 'mount_uidropdown' function
    mountComponent(app, 'mount_uidropdown', parent, props);
else
    % Construct the component with its updated Tag 
    constructComponent(app, 'DeleteEventsInput', parent, {
        'Items', [{'Select...'}; unique(app.ACT.analysis.events.label(strcmpi(app.ACT.analysis.events.type, 'customEvent') | strcmpi(app.ACT.analysis.events.label, 'reject')))]; ...
        'Value', 'Select...'; ...
        });
end
% -----
% Delete UIButton
% -----
% Check if component should mount
if shouldComponentMount(app, parent, 'DeleteEventsDeleteButton')
    % Set Layout
    Layout = app.DataPanel.Layout;
    Layout.Row = 1;
    Layout.Column = 2;
    % Set UserData
    UserData.input = 'deleteEvents';
    UserData.type = 'events';
    % Create properties
    props = {
        'Tag', 'DeleteEventsDeleteButton'; ...
        'Text', ''; ...
        'Icon', 'iconTrash.png'; ...
        'BackgroundColor', [0.90, 0.18, 0.18]; ...
        'Layout', Layout; ...
        'UserData', UserData; ...
        };
    % Mount component using the 'mount_uibutton' function
    mountComponent(app, 'mount_uibutton', parent, props);
end

end % EOF
