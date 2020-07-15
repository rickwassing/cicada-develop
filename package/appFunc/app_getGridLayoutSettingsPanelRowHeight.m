function RowHeight = app_getGridLayoutSettingsPanelRowHeight(app)

% There are two static rows with components in them, so take their row heights
RowHeight = app.GridLayoutSettingsPanel.RowHeight(1:2);

% If there are no other fields, we're done here
if ~isfield(app.ACT.display, 'order')
    return
end

% If there are more fields ...
for di = 1:length(app.ACT.display.order)
    % ... get how many fields are part of this data type
    if isfield(app.ACT.display, app.ACT.display.order{di})
        fnames = fieldnames(app.ACT.display.(app.ACT.display.order{di}).field);
    else
        fnames = fieldnames(app.ACT.data.(app.ACT.display.order{di}));
    end
    % Add a row to the parent gridlayout
    RowHeight = [RowHeight, {91 + 21*length(fnames)}];
end

% Finally, we add two more rows to accomodate annotation type and sleep window type panels
RowHeight = [RowHeight, {47}, {47}, {47}];

end