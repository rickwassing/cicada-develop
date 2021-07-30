function [y,idx] = rollCellFun(h, x, k, varargin)

% Initialize the varargin parser
p = inputParser;
% If the user wants to add an event, a 'label' and 'type' must be provided
addParameter(p, 'fill', true, ...
    @(x) validateattributes(x, {'logical'}, {'nonempty', 'scalar'}) ...
);
addParameter(p, 'step', 1, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'integer', 'positive'}) ...
);
% Parse the variable arguments
parse(p,varargin{:});

fill = p.Results.fill;
step = p.Results.step;

% The window starts half a window before, and ends half a window after the index
winSampleStart = ceil(k/2);
winSampleEnd   = floor(k/2);

if fill % if the window does not fit, then shift the window right or left
    C = cell(1,length(1:step:length(x)));
    I = nan(2,length(1:step:length(x)));
    cnt=0;
    for i = 1:step:length(x)
        idx = i-winSampleStart+1:i+winSampleEnd;
        if any(idx<1) % the window overlaps with non-positive indices
            idx = idx - min(idx) + 1; % so shift the window right
        end
        if any(idx>length(x)) % the window overlaps with indices larger than length(x)
            idx = idx - (max(idx)-length(x)); % so shift the window left
        end
        cnt = cnt+1;
        I(:,cnt) = [idx(1); idx(end)];
        C{cnt} = x(idx);
    end
    idx = 1:step:length(x);
else % only use windows that fit in [1:length(x)]
    C = cell(1,length(1:step:length(x)-k));
    I = nan(2,length(1:step:length(x)-k));
    cnt=0;
    for i = 1:step:length(x)-k+1
        idx = i:i+k-1;
        cnt = cnt+1;
        I(:,cnt) = [idx(1); idx(end)];
        C{cnt} = x(idx);
    end
    idx = round(mean(I));
end

y = cellfun(h, C);