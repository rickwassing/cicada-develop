function parent = app_constructSettingsPanelInput(app, parent, type, fnames)

% ---------------------------------------------------------
% Height label
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['RowSpanLabel_', type])
    parent.UserData.RowSpanLabel = uilabel(parent);
    parent.UserData.RowSpanLabel.Tag = ['RowSpanLabel_', type];
    parent.UserData.RowSpanLabel.Layout.Row = 1;
    parent.UserData.RowSpanLabel.Layout.Column = 1;
    parent.UserData.RowSpanLabel.Text = 'Height';
    parent.UserData.RowSpanLabel.FontSize = 10;
    parent.UserData.RowSpanLabel.HorizontalAlignment = 'right';
end
% ---------------------------------------------------------
% Height input
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['RowSpanInput_', type])
    parent.UserData.RowSpanInput = uispinner(parent);
    parent.UserData.RowSpanInput.Tag = ['RowSpanInput_', type];
    parent.UserData.RowSpanInput.Layout.Row = 1;
    parent.UserData.RowSpanInput.Layout.Column = 2;
    parent.UserData.RowSpanInput.Value = app.ACT.display.(type).rowspan;
    parent.UserData.RowSpanInput.Limits = [1, 5];
    parent.UserData.RowSpanInput.FontSize = 10;
    parent.UserData.RowSpanInput.UserData.type = type;
    parent.UserData.RowSpanInput.UserData.input = 'rowspan';
    parent.UserData.RowSpanInput.ValueChangedFcn = {@app.EventListener};
else
    % Construct the component with its updated Value 
    parent.UserData.RowSpanInput.Value = app.ACT.display.(type).rowspan;
end
% ---------------------------------------------------------
% Height unit label
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['RowSpanUnitLabel_', type])
    parent.UserData.RowSpanUnitLabel = uilabel(parent);
    parent.UserData.RowSpanUnitLabel.Tag = ['RowSpanUnitLabel_', type];
    parent.UserData.RowSpanUnitLabel.Layout.Row = 1;
    parent.UserData.RowSpanUnitLabel.Layout.Column = 3;
    parent.UserData.RowSpanUnitLabel.Text = 'x';
    parent.UserData.RowSpanUnitLabel.FontSize = 10;
    parent.UserData.RowSpanUnitLabel.FontColor = [0.5, 0.5, 0.5];
end
% ---------------------------------------------------------
% Show label
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['ShowLabel_', type])
    parent.UserData.ShowLabel = uilabel(parent);
    parent.UserData.ShowLabel.Tag = ['ShowLabel_', type];
    parent.UserData.ShowLabel.Layout.Row = 2;
    parent.UserData.ShowLabel.Layout.Column = 1;
    parent.UserData.ShowLabel.Text = 'Show';
    parent.UserData.ShowLabel.FontSize = 10;
    parent.UserData.ShowLabel.HorizontalAlignment = 'right';
end
% ---------------------------------------------------------
% Show check box
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['ShowInput_', type])
    parent.UserData.ShowInput = uicheckbox(parent);
    parent.UserData.ShowInput.Tag = ['ShowInput_', type];
    parent.UserData.ShowInput.Layout.Row = 2;
    parent.UserData.ShowInput.Layout.Column = 2;
    parent.UserData.ShowInput.Value = app.ACT.display.(type).show;
    parent.UserData.ShowInput.Text = '';
    parent.UserData.ShowInput.UserData.type = type;
    parent.UserData.ShowInput.UserData.input = 'show';
    parent.UserData.ShowInput.ValueChangedFcn = {@app.EventListener};
else
    % Construct the component with its updated Value
    parent.UserData.ShowInput.Value = app.ACT.display.(type).show;
end
% ---------------------------------------------------------
% Log10 check box
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['LogInput_', type])
    parent.UserData.LogInput = uicheckbox(parent);
    parent.UserData.LogInput.Tag = ['LogInput_', type];
    parent.UserData.LogInput.Layout.Row = 2;
    parent.UserData.LogInput.Layout.Column = 3;
    parent.UserData.LogInput.Value = app.ACT.display.(type).log;
    parent.UserData.LogInput.Text = 'log';
    parent.UserData.LogInput.FontSize = 10;
    parent.UserData.LogInput.UserData.type = type;
    parent.UserData.LogInput.UserData.input = 'log';
    parent.UserData.LogInput.ValueChangedFcn = {@app.EventListener};
else
    % Construct the component with its updated Value
    parent.UserData.LogInput.Value = app.ACT.display.(type).log;
end
% ---------------------------------------------------------
% Range label
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['RangeLabel_', type])
    parent.UserData.RangeLabel = uilabel(parent);
    parent.UserData.RangeLabel.Tag = ['RangeLabel_', type];
    parent.UserData.RangeLabel.Layout.Row = 3;
    parent.UserData.RangeLabel.Layout.Column = 1;
    parent.UserData.RangeLabel.Text = 'Range';
    parent.UserData.RangeLabel.FontSize = 10;
    parent.UserData.RangeLabel.HorizontalAlignment = 'right';
end
% ---------------------------------------------------------
% Minimum Range input
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['RangeInputMin_', type])
    parent.UserData.RangeInputMin = uieditfield(parent, 'numeric');
    parent.UserData.RangeInputMin.Tag = ['RangeInputMin_', type];
    parent.UserData.RangeInputMin.Layout.Row = 3;
    parent.UserData.RangeInputMin.Layout.Column = 2;
    parent.UserData.RangeInputMin.Value = app.ACT.display.(type).range(1);
    parent.UserData.RangeInputMin.ValueDisplayFormat = '%.1f';
    parent.UserData.RangeInputMin.FontSize = 10;
    parent.UserData.RangeInputMin.HorizontalAlignment = 'center';
    parent.UserData.RangeInputMin.UserData.type = type;
    parent.UserData.RangeInputMin.UserData.input = 'range';
    parent.UserData.RangeInputMin.UserData.idx = 1;
    parent.UserData.RangeInputMin.ValueChangedFcn = {@app.EventListener};
else
    % Construct the component with its updated Value
    parent.UserData.RangeInputMin.Value = app.ACT.display.(type).range(1);
end
% ---------------------------------------------------------
% Maximum Range input
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['RangeInputMax_', type])
    parent.UserData.RangeInputMax = uieditfield(parent, 'numeric');
    parent.UserData.RangeInputMax.Tag = ['RangeInputMax_', type];
    parent.UserData.RangeInputMax.Layout.Row = 3;
    parent.UserData.RangeInputMax.Layout.Column = 3;
    parent.UserData.RangeInputMax.Value = app.ACT.display.(type).range(2);
    parent.UserData.RangeInputMax.ValueDisplayFormat = '%.1f';
    parent.UserData.RangeInputMax.HorizontalAlignment = 'center';
    parent.UserData.RangeInputMax.FontSize = 10;
    parent.UserData.RangeInputMax.UserData.type = type;
    parent.UserData.RangeInputMax.UserData.input = 'range';
    parent.UserData.RangeInputMax.UserData.idx = 2;
    parent.UserData.RangeInputMax.ValueChangedFcn = {@app.EventListener};
else
    % Construct the component with its updated Value
    parent.UserData.RangeInputMax.Value = app.ACT.display.(type).range(2);
end
% ---------------------------------------------------------
% field name panel
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent, ['FieldSettingsPanel_', type])
    parent.UserData.FieldSettingsPanel = uipanel(parent);
    parent.UserData.FieldSettingsPanel.Tag = ['FieldSettingsPanel_', type];
    parent.UserData.FieldSettingsPanel.Layout.Row = 4;
    parent.UserData.FieldSettingsPanel.Layout.Column = [1, 3];
    parent.UserData.FieldSettingsPanel.Title = '';
    parent.UserData.FieldSettingsPanel.FontSize = 10;
    parent.UserData.FieldSettingsPanel.BackgroundColor = [0.98, 0.98, 0.98];
end
% ---------------------------------------------------------
% field name gridlayout
% ---------------------------------------------------------
% Check if component should mount
if shouldComponentMount(app, parent.UserData.FieldSettingsPanel, ['FieldSettingsGridLayout_', type])
    parent.UserData.FieldSettingsGridLayout = uigridlayout(parent.UserData.FieldSettingsPanel);
    parent.UserData.FieldSettingsGridLayout.Tag = ['FieldSettingsGridLayout_', type];
    parent.UserData.FieldSettingsGridLayout.RowHeight = repmat(18, 1, length(fnames));
    parent.UserData.FieldSettingsGridLayout.ColumnWidth = {'1x', 46, 18, 18, 18};
    parent.UserData.FieldSettingsGridLayout.RowSpacing = 3;
    parent.UserData.FieldSettingsGridLayout.ColumnSpacing = 3;
    parent.UserData.FieldSettingsGridLayout.Padding = [3, 3, 3, 3];
end
% ---------------------------------------------------------
for fi = 1:length(fnames)
    % ---------------------------------------------------------
    % field label
    % ---------------------------------------------------------
    % Check if component should mount
    if shouldComponentMount(app, parent.UserData.FieldSettingsGridLayout, ['FieldLabel_', fnames{fi}])
        parent.UserData.(['FieldLabel_', fnames{fi}]) = uilabel(parent.UserData.FieldSettingsGridLayout);
        parent.UserData.(['FieldLabel_', fnames{fi}]).Tag = ['FieldLabel_', fnames{fi}];
        parent.UserData.(['FieldLabel_', fnames{fi}]).Layout.Row = fi;
        parent.UserData.(['FieldLabel_', fnames{fi}]).Layout.Column = 1;
        parent.UserData.(['FieldLabel_', fnames{fi}]).Text = fnames{fi};
        parent.UserData.(['FieldLabel_', fnames{fi}]).FontSize = 10;
        parent.UserData.(['FieldLabel_', fnames{fi}]).FontAngle = 'italic';
    end
    % ---------------------------------------------------------
    % Show check box
    % ---------------------------------------------------------
    % Check if component should mount
    if shouldComponentMount(app, parent.UserData.FieldSettingsGridLayout, ['FieldShowInput_', fnames{fi}])
        parent.UserData.(['FieldShowInput_', fnames{fi}]) = uicheckbox(parent.UserData.FieldSettingsGridLayout);
        parent.UserData.(['FieldShowInput_', fnames{fi}]).Tag = ['FieldShowInput_', fnames{fi}];
        parent.UserData.(['FieldShowInput_', fnames{fi}]).Layout.Row = fi;
        parent.UserData.(['FieldShowInput_', fnames{fi}]).Layout.Column = 2;
        parent.UserData.(['FieldShowInput_', fnames{fi}]).Value = app.ACT.display.(type).field.(fnames{fi}).show;
        parent.UserData.(['FieldShowInput_', fnames{fi}]).Text = 'Show';
        parent.UserData.(['FieldShowInput_', fnames{fi}]).FontSize = 10;
        parent.UserData.(['FieldShowInput_', fnames{fi}]).ValueChangedFcn = {@app.EventListener};
        parent.UserData.(['FieldShowInput_', fnames{fi}]).UserData.type = type;
        parent.UserData.(['FieldShowInput_', fnames{fi}]).UserData.field = fnames{fi};
        parent.UserData.(['FieldShowInput_', fnames{fi}]).UserData.input = 'show';
    else
        % Construct the component with its updated Value
        parent.UserData.(['FieldShowInput_', fnames{fi}]).Value = app.ACT.display.(type).field.(fnames{fi}).show;
    end
    % ---------------------------------------------------------
    % Color Button
    % ---------------------------------------------------------
    % Check if component should mount
    if shouldComponentMount(app, parent.UserData.FieldSettingsGridLayout, ['FieldClrButton_', fnames{fi}])
        parent.UserData.(['FieldClrButton_', fnames{fi}]) = uibutton(parent.UserData.FieldSettingsGridLayout);
        parent.UserData.(['FieldClrButton_', fnames{fi}]).Tag = ['FieldClrButton_', fnames{fi}];
        parent.UserData.(['FieldClrButton_', fnames{fi}]).Layout.Row = fi;
        parent.UserData.(['FieldClrButton_', fnames{fi}]).Layout.Column = 3;
        parent.UserData.(['FieldClrButton_', fnames{fi}]).Text = '';
        parent.UserData.(['FieldClrButton_', fnames{fi}]).BackgroundColor = app.ACT.display.(type).field.(fnames{fi}).clr;
        parent.UserData.(['FieldClrButton_', fnames{fi}]).ButtonPushedFcn = {@app.EventListener};
        parent.UserData.(['FieldClrButton_', fnames{fi}]).UserData.type = type;
        parent.UserData.(['FieldClrButton_', fnames{fi}]).UserData.field = fnames{fi};
        parent.UserData.(['FieldClrButton_', fnames{fi}]).UserData.input = 'color';
    else
        % Construct the component with its updated BackgroundColor
        parent.UserData.(['FieldClrButton_', fnames{fi}]).BackgroundColor = app.ACT.display.(type).field.(fnames{fi}).clr;
    end
    % ---------------------------------------------------------
    % Up Button
    % ---------------------------------------------------------
    % Check if component should mount
    if shouldComponentMount(app, parent.UserData.FieldSettingsGridLayout, ['FieldUpButton_', fnames{fi}])
        parent.UserData.(['FieldUpButton_', fnames{fi}]) = uibutton(parent.UserData.FieldSettingsGridLayout);
        parent.UserData.(['FieldUpButton_', fnames{fi}]).Tag = ['FieldUpButton_', fnames{fi}];
        parent.UserData.(['FieldUpButton_', fnames{fi}]).Layout.Row = fi;
        parent.UserData.(['FieldUpButton_', fnames{fi}]).Layout.Column = 4;
        parent.UserData.(['FieldUpButton_', fnames{fi}]).Text = '^';
        parent.UserData.(['FieldUpButton_', fnames{fi}]).FontSize = 8;
        parent.UserData.(['FieldUpButton_', fnames{fi}]).UserData.type = type;
        parent.UserData.(['FieldUpButton_', fnames{fi}]).UserData.input = 'moveField';
        parent.UserData.(['FieldUpButton_', fnames{fi}]).UserData.field = fnames{fi};
        parent.UserData.(['FieldUpButton_', fnames{fi}]).UserData.direction = -1;
        parent.UserData.(['FieldUpButton_', fnames{fi}]).ButtonPushedFcn = {@app.EventListener};
    end
    if fi == 1
        parent.UserData.(['FieldUpButton_', fnames{fi}]).Enable = 'off';
    else
        parent.UserData.(['FieldUpButton_', fnames{fi}]).Enable = 'on';
    end
    % ---------------------------------------------------------
    % Down Button
    % ---------------------------------------------------------
    % Check if component should mount
    if shouldComponentMount(app, parent.UserData.FieldSettingsGridLayout, ['FieldDownButton_', fnames{fi}])
        parent.UserData.(['FieldDownButton_', fnames{fi}]) = uibutton(parent.UserData.FieldSettingsGridLayout);
        parent.UserData.(['FieldDownButton_', fnames{fi}]).Tag = ['FieldDownButton_', fnames{fi}];
        parent.UserData.(['FieldDownButton_', fnames{fi}]).Layout.Row = fi;
        parent.UserData.(['FieldDownButton_', fnames{fi}]).Layout.Column = 5;
        parent.UserData.(['FieldDownButton_', fnames{fi}]).Text = 'v';
        parent.UserData.(['FieldDownButton_', fnames{fi}]).FontSize = 8;
        parent.UserData.(['FieldDownButton_', fnames{fi}]).UserData.type = type;
        parent.UserData.(['FieldDownButton_', fnames{fi}]).UserData.input = 'moveField';
        parent.UserData.(['FieldDownButton_', fnames{fi}]).UserData.field = fnames{fi};
        parent.UserData.(['FieldDownButton_', fnames{fi}]).UserData.direction = 1;
        parent.UserData.(['FieldDownButton_', fnames{fi}]).ButtonPushedFcn = {@app.EventListener};
    end
    if fi == length(fnames)
        parent.UserData.(['FieldDownButton_', fnames{fi}]).Enable = 'off';
    else
        parent.UserData.(['FieldDownButton_', fnames{fi}]).Enable = 'on';
    end
end

end % EOF
