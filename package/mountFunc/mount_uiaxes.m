function Component = mount_uiaxes(app, parent, props, varargin)

if nargin < 4
    destructurise = false;
else
    destructurise = varargin{:};
end

% Mount
Component = uiaxes(parent);

% Set default properties
Component.TickLength = [0, 0];
Component.Toolbar = [];
Component.Interactions = [];
Component.NextPlot = 'add';

colormap(Component, mount_colormap('log2'));

% Set the input properties
for pi = 1:size(props, 1)
    Component.(props{pi, 1}) = props{pi, 2};
end
Component.UserData.props = props;

% *****
% * ISSUE 4
% *****
if destructurise
    DestrComponent = struct(Component);
    DestrComponent.Axes.UserData.input = 'cursor';
    DestrComponent.Axes.UserData.type = '';
    DestrComponent.Axes.ButtonDownFcn = {@app.EventListener};
    if isempty(Component.XTickLabel)
        DestrComponent.Axes.Position = DestrComponent.Axes.Position + [0, -5, 0, 5];
    end
end

end % EOF
