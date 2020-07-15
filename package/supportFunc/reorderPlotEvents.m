function parent = reorderPlotEvents(app, parent)

o = struct();
o.other = [];
o.start = [];
o.leastActivity = [];
o.mostActivity = [];
o.button = [];
o.customEvent = [];
o.reject = [];
o.waso = [];
o.sleepPeriod = [];
o.sleepWindow = [];
for ch = 1:length(parent.Children)
    % Check if this is indeed an event
    if ~strcmpi(parent.Children(ch).Tag(1:5), 'Event')
        o.other = [o.other, ch];
    else
        idx = app.ACT.events.id == parent.Children(ch).UserData.id;
        if ~any(idx)
            % Disregard this object, it will be deleted
            o.other = [o.other, ch];
            continue
        end
        label = app.ACT.events.label{idx};
        type  = app.ACT.events.type{idx};
        if strcmpi(type, 'customEvent')
            o.(type) = [o.(type), ch];
        else
            o.(label) = [o.(label), ch];
        end
    end
end

idx = [];
for field = {'other', 'start', 'leastActivity', 'mostActivity', 'button', 'customEvent', 'reject', 'waso', 'sleepPeriod', 'sleepWindow'}
    idx = [idx; o.(field{:})'];
end

parent.Children = parent.Children(idx);

end