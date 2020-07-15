function Component = mount_text(app, parent, props)

% Extract values required to mount the component
Position = props{strcmpi(props(:, 1), 'Position'), 2};
String = props{strcmpi(props(:, 1), 'String'), 2};

% Mount
Component = text(parent, Position(1), Position(2), String);

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end
Component.UserData.props = props;

end  % EOF
