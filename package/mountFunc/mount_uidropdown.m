function Component = mount_uidropdown(app, parent, props)

% Mount
Component = uidropdown(parent);

% Set default properties
Component.ValueChangedFcn = {@app.EventListener};

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end
Component.UserData.props = props;

end % EOF
