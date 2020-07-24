function [ACT, id] = cic_editEvents(ACT, method, onset, duration, varargin)
% ---------------------------------------------------------
% method:   'add',     add events
%           'edit',    update one event given by the ID: 
%                      provide argument 'id', <integer>
%           'delete',  delete any event given some label or type, or both
% onset:    Column vector, N-by-1
% duration: Column vector, N-by-1, of same length as 'onset'
% varargin: 'id',    <scalar> - required for 'edit'
%           'label', <char>   - required for 'add'
% 	        'type',  <char>   - required for 'add'
% ---------------------------------------------------------
% Initialize the varargin parser
p = inputParser;
% ---------------------------------------------------------
% Before we do anything, make sure the 'start' event is in the table with its ID as the maximum among all IDs
if ~any(strcmpi(ACT.analysis.events.label, 'start'))
    add = table();
    add.id = ifelse(isempty(ACT.analysis.events.id), 1, max(ACT.analysis.events.id)+1);
    add.onset = ACT.xmin;
    add.duration = 0;
    add.label = {'start'};
    add.type = {''};
    ACT.analysis.events = [ACT.analysis.events; add];
elseif sum(strcmpi(ACT.analysis.events.label, 'start')) > 1
    ACT.analysis.events(strcmpi(ACT.analysis.events.label, 'start'), :) = [];
    add = table();
    add.id = ifelse(isempty(ACT.analysis.events.id), 1, max(ACT.analysis.events.id)+1);
    add.onset = ACT.xmin;
    add.duration = 0;
    add.label = {'start'};
    add.type = {''};
    ACT.analysis.events = [ACT.analysis.events; add];
end
    
% ---------------------------------------------------------
if ~strcmpi(method, 'delete') % 'onset' and 'duration' are not required for deleting events
    % Make sure onset and duration are not empty
    if isempty(onset) || isempty(duration)
        return
    end
    % Make sure onset and duration are column vectors of equal length
    if ~any(size(onset) == 1)
        error('''onset'' must be a column vector, N-by-1')
    end
    if ~any(size(duration) == 1)
        error('''duration'' must be a column vector, N-by-1')
    end
    if size(onset, 1) == 1; onset = onset'; end
    if size(duration, 1) == 1; duration = duration'; end
    if length(onset) ~= length(duration)
        error('''onset'' and ''duration'' must be of equal length')
    end
end
% ---------------------------------------------------------
switch method
    case 'add'
        % If the user wants to add an event, a 'label' and 'type' must be provided
        addParameter(p, 'label', [], ...
        	@(x) validateattributes(x, {'char'}, {'nonempty'}) ...
        );
        addParameter(p, 'type', [], ...
        	@(x) validateattributes(x, {'char'}, {'nonempty'}) ...
        );
        % Parse the variable arguments
        parse(p,varargin{:});
        % Create a new table with new events
        id = (max(ACT.analysis.events.id)+1:max(ACT.analysis.events.id)+length(onset))';
        add = table();
        add.id = id;
        add.onset = onset;
        add.duration = duration;
        add.label = repmat({p.Results.label},length(onset),1);
        add.type = repmat({p.Results.type},length(onset),1);
        % Add the new table to the events table
        ACT.analysis.events = [ACT.analysis.events; add];
        % replace the 'start' event ID with the largest ID+1 so
        % future new events will not re-use IDs of previously defined events
        if ACT.analysis.events.id(strcmpi(ACT.analysis.events.label, 'start')) <= max(ACT.analysis.events.id)
            ACT.analysis.events.id(strcmpi(ACT.analysis.events.label, 'start')) = max(ACT.analysis.events.id)+1;
        end
    case 'edit'
        % If the user wants to edit an event, an 'id' must be provided
        addParameter(p,'id',[], ...
            @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'nonzero', 'positive'}) ... 
        );
        % 'Label' and 'Type' are optional
        addParameter(p,'label',[], ...
        	@(x) validateattributes(x, {'char'}, {'nonempty'}) ...
        );
        addParameter(p,'type',[], ...
        	@(x) validateattributes(x, {'char'}, {'nonempty'}) ...
        );
        % Parse the variable arguments
        parse(p,varargin{:});
        % Also, 'onset', and 'duration' must be scalars
        if ~isscalar(onset) || ~isscalar(duration)
            error('''onset'' and ''duration'' must be scalars')
        end
        % Update the onset and duration of the event
        id = p.Results.id;
        idx = ACT.analysis.events.id == id;
        ACT.analysis.events.onset(idx) = onset;
        ACT.analysis.events.duration(idx) = duration;
        if ~isempty(p.Results.label)
            ACT.analysis.events.label{idx} = p.Results.label;
        end
        if ~isempty(p.Results.type)
            ACT.analysis.events.type{idx} = p.Results.type;
        end
    case 'delete'
        % If the user wants to delete an event, an 'id', 'label' and/or 'type' must be provided
        addParameter(p,'id', [] , ...
            @(x) validateattributes(x, {'numeric'}, {'integer', 'nonzero', 'positive'}) ... 
        );
        addParameter(p,'label',[], ...
            @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
        );
        addParameter(p,'type',[], ...
            @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
        );
        % Parse the variable arguments
        parse(p, varargin{:});

        % If the user did not specify a label or type, do nothing
        if isempty(p.Results.id) && isempty(p.Results.label) && isempty(p.Results.type)
            return
        else % Otherwise, at leasts a label or a type has been specified
            if ~isempty(p.Results.id) % If the user specified an id
                idx = ismember(ACT.analysis.events.id, p.Results.id);
            elseif isempty(p.Results.type) % If the user specified a label, but not a type
                idx = strcmpi(ACT.analysis.events.label, p.Results.label);
            elseif isempty(p.Results.label) % If the user specified a type, but not a label
                idx = strcmpi(ACT.analysis.events.type, p.Results.type);
            elseif ~isempty(p.Results.type) && ~isempty(p.Results.label) % If the user specified a label and a type
                idx = strcmpi(ACT.analysis.events.label, p.Results.label) & strcmpi(ACT.analysis.events.type, p.Results.type);
            end
        end
        % Get the IDs from the to-be deleted events
        id = ACT.analysis.events.id(idx);
        if any(idx)
            % Delete the events, and replace the 'start' event ID with the largest deleted ID so
            % future new events will not re-use IDs of previously deleted events
            ACT.analysis.events(idx, :) = [];
            if ACT.analysis.events.id(strcmpi(ACT.analysis.events.label, 'start')) <= max(id)
                ACT.analysis.events.id(strcmpi(ACT.analysis.events.label, 'start')) = max(id)+1;
            end
        end
end
% ---------------------------------------------------------
% Sort the events table
[~, idx] = sort(ACT.analysis.events.onset);
ACT.analysis.events = ACT.analysis.events(idx, :);
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');

end % EOF
