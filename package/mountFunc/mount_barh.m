function Component = mount_barh(app, parent, props)

% Extract values required to mount the component
YData = props{strcmpi(props(:, 1), 'YData'), 2};

% For some unknown reason, the barh function updates the XTick on the parent even though it is set to 'manual'.
XTick = parent.XTick;

% Mount
Component = barh(parent, YData);

% Set default properties
Component.PickableParts = 'none';

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end
Component.UserData.props = props;

% Revert back to the original XTick
parent.XTick = XTick;
parent.YTick = [];

end
