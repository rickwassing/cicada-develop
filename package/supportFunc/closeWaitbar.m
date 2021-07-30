function closeWaitbar()
app = findall(groot, 'Name', 'Cicada');
if isvalid(app)
    app = app.RunningAppInstance;
else
    app = [];
end
if isempty(app) % There is no app so return
    return
end
if ~isempty(app.Waitbar)
    close(app.Waitbar)
    app.Waitbar = [];
end
end