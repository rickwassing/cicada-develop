function Component = mount_uitab(app, parent, props)

% Mount
Component = uitab(parent);

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end

end % EOF
