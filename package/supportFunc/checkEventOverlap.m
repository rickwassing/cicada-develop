function [error, message] = checkEventOverlap(app, event)

% Assume all is right
error = false;
message = {''};

switch event.label
    case 'sleepWindow'
        % If the slepe window type is not set yet, set it to 'manual'
        if ~isfield(app.ACT.analysis.settings, 'sleepWindowType')
            app.ACT.analysis.settings.sleepWindowType = 'manual';
        end
        % Check if the new event overlaps with existing events of this same sleep window type
        events = selectEventsUsingTime(app.ACT.events, event.onset, event.onset+event.duration, ...
            'Label', 'sleepWindow', ...
            'Type', {'manual', app.ACT.analysis.settings.sleepWindowType}, ...
            'Enclosed', false);
        % Do not check with events that have the same ID, as an event cannot overlap with itself
        events(events.id == event.id, :) = [];
        if ~isempty(events)
            error = true;
            message = [{'Cancelled: you defined a sleep window that overlaps with an existing sleep window of type:'}; unique(events.type(:))];
            return
        end
        % Check if the new event overlaps with existing reject intervals
        events = selectEventsUsingTime(app.ACT.events, event.onset, event.onset+event.duration, ...
            'Label', 'reject', ...
            'Enclosed', false);
        % Do not check with events that have the same ID, as an event cannot overlap with itself
        events(events.id == event.id, :) = [];
        if ~isempty(events)
            error = true;
            message = 'Cancelled: you defined a sleep window that overlaps with an existing rejected window.';
            return
        end
        % In case the user defines a manual sleep interval in a set of
        % sleep windows of another type, all sleep events will be copied
        % over to the 'manual' set, so we have to check whether the sleep
        % windows of the current type overlaps with any sleep window of the
        % 'manual' type
        if ~strcmpi(app.ACT.analysis.settings.sleepWindowType, 'manual')
            thisEvents = selectEventsUsingTime(app.ACT.events, app.ACT.xmin, app.ACT.xmax, ...
                'Label', 'sleepWindow', ...
                'Type', app.ACT.analysis.settings.sleepWindowType, ...
                'Enclosed', false);
            [error, message] = checkEventOverlapWithManualSleepWindow(app, thisEvents);
            if error
                return
            end
        end
    case 'reject'
        events = selectEventsUsingTime(app.ACT.events, event.onset, event.onset+event.duration, ...
            'Label', 'reject', ...
            'Enclosed', false);
        % Do not check with events that have the same ID, as an event cannot overlap with itself
        events(events.id == event.id, :) = [];
        if ~isempty(events)
            error = true;
            message = {'Cancelled: you rejected a window that overlaps with an existing rejected window.'};
            return
        end
        events = selectEventsUsingTime(app.ACT.events, event.onset, event.onset+event.duration, ...
            'Label', 'sleepWindow', ...
            'Type', app.ACT.analysis.settings.sleepWindowType, ...
            'Enclosed', false);
        % Do not check with events that have the same ID, as an event cannot overlap with itself
        events(events.id == event.id, :) = [];
        if ~isempty(events)
            error = true;
            message = {'Cancelled: you rejected a window that overlaps with an existing sleep window.'};
            return
        end
end
end