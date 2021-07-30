function idx = events2idx(ACT, time, varargin)

% Initialize the varargin parser
p = inputParser;
% If the user wants to extract an event, an ('id') OR a ('label' AND/OR 'type') can be provided
% Otherwise, all events will be returned
addParameter(p, 'label', [], ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
);
addParameter(p, 'type', [], ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
);
addParameter(p,'id',[], ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'nonzero', 'positive'}) ... 
);
% Parse the variable arguments
parse(p, varargin{:});

if nargin < 3
    id = ACT.analysis.events.id;
else
    if ~isempty(p.Results.id)
        id = p.Results.id;
    elseif isempty(p.Results.label)
        id = ACT.analysis.events.id(strcmpi(ACT.analysis.events.type, p.Results.type));
    elseif isempty(p.Results.type)
        id = ACT.analysis.events.id(strcmpi(ACT.analysis.events.label, p.Results.label));
    elseif ~isempty(p.Results.type) && ~isempty(p.Results.label)
        id = ACT.analysis.events.id(strcmpi(ACT.analysis.events.label, p.Results.label) & strcmpi(ACT.analysis.events.type,p.Results.type));
    else
        id = [];
    end
end

idx = false(size(time));

for ev = 1:length(id)
    idxEvent = ACT.analysis.events.id == id(ev);
    onset  = find(time >= ACT.analysis.events.onset(idxEvent), 1, 'first');
    offset = find(time <= (ACT.analysis.events.onset(idxEvent) + ACT.analysis.events.duration(idxEvent)), 1, 'last');
    if isempty(onset) || isempty(offset)
        continue
    end
    idx(onset:offset) = true;
end