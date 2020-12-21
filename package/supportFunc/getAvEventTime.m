function time = getAvEventTime(ACT, eventMetric, varargin)

% Initialize the varargin parser
p = inputParser;
% If the user wants to add an event, a 'label' and 'type' must be provided
addParameter(p,'label',[], ...
    @(x) validateattributes(x,{'char'},{'nonempty'}) ...
);
addParameter(p,'type',[], ...
    @(x) validateattributes(x,{'char'},{'nonempty'}) ...
);
addParameter(p, 'startDate', ACT.xmin, ...
    @(x) validateattributes(x,{'numeric'},{'nonempty','scalar','positive'}) ...
);
addParameter(p, 'endDate', ACT.xmax, ...
    @(x) validateattributes(x,{'numeric'},{'nonempty','scalar','positive'}) ...
);
addParameter(p, 'select', 'all', ...
    @(x) validateattributes(x, {'char', 'cell'}, {'nonempty'}) ...
);
addParameter(p, 'selectCriterium', 'offset', ...
    @(x) validateattributes(x, {'char', 'cell'}, {'nonempty'}) ...
);
% Parse the variable arguments
parse(p,varargin{:});

% If the user did not specify a label or type, return this is required
if isempty(p.Results.label) && isempty(p.Results.type)
    error('No event label or type specified')
else
    % If the user specified a label, but not a type
    if isempty(p.Results.type)
        events = selectEventsUsingTime(ACT.analysis.events, p.Results.startDate, p.Results.endDate, ...
            'label', p.Results.label);
        
    % If the user specified a type, but not a label
    elseif isempty(p.Results.label)
        events = selectEventsUsingTime(ACT.analysis.events, p.Results.startDate, p.Results.endDate, ...
            'type', p.Results.type);
        
    % If the user specified a label and a type
    elseif ~isempty(p.Results.type) && ~isempty(p.Results.label)
        events = selectEventsUsingTime(ACT.analysis.events, p.Results.startDate, p.Results.endDate, ...
            'type', p.Results.type, ...
            'label', p.Results.label);
        
    end
end

% If the user specified, keep only the events in the week or weekend
switch p.Results.select
    case 'week'
        if strcmpi(p.Results.selectCriterium, 'offset')
            idxSelect = weekday(events.onset + events.duration) >= 2 & weekday(events.onset + events.duration) <= 6; % Monday (2) to Friday (6)
        elseif strcmpi(p.Results.selectCriterium, 'onset')
            idxSelect = weekday(events.onset) >= 2 & weekday(events.onset) <= 6; % Monday (2) to Friday (6)
        end
    case 'weekend'
        if strcmpi(p.Results.selectCriterium, 'offset')
            idxSelect = weekday(events.onset + events.duration) == 1 | weekday(events.onset + events.duration) == 7; % Sunday (1) or Saturday (7)
        elseif strcmpi(p.Results.selectCriterium, 'onset')
            idxSelect = weekday(events.onset) == 1 | weekday(events.onset) == 7; % Sunday (1) or Saturday (7)
        end
    otherwise
        idxSelect = 1:size(events, 1);
end

events = events(idxSelect, :);

if isempty(events)
    time = 'na';
    return
end

% If the user requests the average duration: calculate mean and return
if strcmp(eventMetric, 'duration')
    time = mean(events.duration);
    return
% If the user requests the average onset, midpoint or offset: take the modulus to get
% the onset/offset time for each day, irrespective of the date.
elseif strcmp(eventMetric, 'onset')
    times = mod(events.onset, 1);
elseif strcmp(eventMetric, 'midpoint')
    times = mod(events.onset + (events.duration / 2), 1);
elseif strcmp(eventMetric, 'offset')
    times = mod(events.onset + events.duration, 1);
end

% Calculate the angle of the cosine and sine of these values
piTimes = map(times, 0, 1, -pi, pi);
phi = angle(cos(piTimes) + 1i*sin(piTimes));

% Calculate the mean cosine and sine to get the average angle
avPhi = angle(mean(cos(phi)) + 1i*mean(sin(phi)));

% Convert the average angle back to time.
time = datestr(map(avPhi, -pi, pi, 0, 1), 'HH:MM');

end
