function Component = mount_uilabel(app, parent, props)

% Mount
Component = uilabel(parent);

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end
Component.UserData.props = props;

end % EOF
