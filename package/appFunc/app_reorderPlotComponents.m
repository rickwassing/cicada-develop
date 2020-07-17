function app_reorderPlotComponents(app, parent, datatype, day)

% Get the current order of the components
currOrder = {parent.Children.Tag};

% Extract the desired order of the components
desOrder = fieldnames(app.ACT.display.(datatype).field);
desOrder = cellfun(@(fname) ['PlotData-', datatype, '_field-', fname, '_day-', num2str(day)], desOrder, 'UniformOutput', false);

% Only keep the desired order of the existing components
desOrder(~ismember(desOrder, currOrder)) = [];

% Get the new indices of the order of the children
newIdx = cell2mat(cellfun(@(tag) find(strcmpi(tag, currOrder)), desOrder, 'UniformOutput', false));

% Reorder the children
parent.Children = parent.Children(newIdx);

end