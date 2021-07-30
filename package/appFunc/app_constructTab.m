function Tab = app_constructTab(app, Tag, Title)

% ---------------------------------------------------------
% UITab
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, app.TabGroup, Tag)
    % Define the properties
    props = { ...
        'Tag', Tag; ...
        'Title',  ['Stats: ', Title]; ...
        };
    % Mount component
    Tab = mountComponent(app, 'mount_uitab', app.TabGroup, props);
    
    % ---------------------------------------------------------
    % Create GridLayout
    GridLayout = uigridlayout(Tab);
    GridLayout.Tag = 'TabGridLayout';
    GridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
    GridLayout.RowHeight = {'1x'};
    
    % ---------------------------------------------------------
    % Create Container
    Container = uipanel(GridLayout);
    Container.Tag = 'TabContainerPanel';
    Container.BorderType = 'none';
    Container.Layout.Row = 1;
    Container.Layout.Column = [1 12];
    Container.FontSize = 10;
    % -----
    % Create Container's GridLayout
    GridLayoutContainer = uigridlayout(Container);
    GridLayoutContainer.Tag = 'TabGridLayoutContainerPanel';
    GridLayoutContainer.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
    GridLayoutContainer.RowHeight = {'1x'};
    GridLayoutContainer.Padding = [0 0 0 0];
    GridLayoutContainer.Scrollable = 'on';
else
    Tab = findobj(app.TabGroup, 'Tag', Tag);
end

end % EOF
