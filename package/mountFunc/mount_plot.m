function Component = mount_plot(app, parent, props)

% Extract values required to mount the component
XData = props{strcmpi(props(:, 1), 'XData'), 2};
YData = props{strcmpi(props(:, 1), 'YData'), 2};

% Mount
Component = plot(parent, XData, YData);

% Set default properties
Component.PickableParts = 'none';

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end
Component.UserData.props = props;

end % EOF
