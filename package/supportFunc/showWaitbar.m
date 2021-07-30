function cancel = showWaitbar(message, value, cancelable)
cancel = false;
app = findall(groot, 'Name', 'Cicada');
if isvalid(app)
    app = app.RunningAppInstance;
else
    app = [];
end
if isempty(app) % There is no app so return
    if value ~= -1
        remainingTime(value);
    end
    return
end
if isempty(app.Waitbar) || ~isvalid(app.Waitbar)
    app.Waitbar = uiprogressdlg(app.CicadaUIFigure);
end
app.Waitbar.Title = 'The Cicada is buzzing, please wait...';
    app.Waitbar.Message = message;
if value == -1
    app.Waitbar.Indeterminate = 'on';
else
    app.Waitbar.Value = value;
    app.Waitbar.Indeterminate = 'off';
end
app.Waitbar.Cancelable = cancelable;
if app.Waitbar.CancelRequested
    cancel = true;
end
end