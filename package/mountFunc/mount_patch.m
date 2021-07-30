function Component = mount_patch(app, parent, props)

% Extract values required to mount the component
XData = props{strcmpi(props(:, 1), 'XData'), 2};
YData = props{strcmpi(props(:, 1), 'YData'), 2};

% Mount
Component = patch(parent, 'XData', XData, 'YData', YData);

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end
Component.UserData.props = props;

% Check if this is an event patch, if so, add event listener
if isfield(Component.UserData, 'eventLabel')
    if ...
            strcmpi(Component.UserData.eventLabel, 'reject') || ...
            strcmpi(Component.UserData.eventType,  'manual') || ...
            strcmpi(Component.UserData.eventType,  'customEvent')
        Component.ButtonDownFcn = @app.EventListener;
    end
end

end