function boutcount = ggirGetBout(x, boutduration, varargin)

% force 'x' to be a double
x = double(x);

% Initialize the varargin parser
p = inputParser;
%
addParameter(p, 'boutcriter', 0.8, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonnan', 'scalar', '>', 0, '<=', 1}) ...
    );
addParameter(p, 'boutClosed', false, ...
    @(x) validateattributes(x, {'logical'}, {'nonempty', 'nonnan', 'scalar'}) ...
    );
addParameter(p, 'boutMetric', 1, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonnan', 'scalar', 'integer','>=' , 1, '<=', 4}) ...
    );
addParameter(p, 'ws3', 5, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonnan', 'scalar', 'integer'}) ...
    );
% Parse the variable arguments
parse(p,varargin{:});

boutcriter = p.Results.boutcriter;
boutClosed = p.Results.boutClosed;
boutMetric = p.Results.boutMetric;
ws3        = p.Results.ws3;

p = find(x == 1); % p are the indices for which the intensity criteria are met

switch boutMetric
    case 1
        xt = x;
        boutcount = zeros(length(x), 1); % initialize zeros as long as there are epochs in the timewindow
        jmvpa = 1; % index for going stepwise through vector p
        while jmvpa <= length(p) % go through all epochs that are possibly part of a bout
            endi = p(jmvpa)+boutduration;
            if endi <= length(x) % does bout fall without measurement?
                if sum(x(p(jmvpa):endi)) > boutduration*boutcriter
                    while sum(x(p(jmvpa):endi)) > (endi-p(jmvpa))*boutcriter && endi < Lx
                        endi = endi + 1;
                    end
                    select = p(jmvpa:find(p < endi,1,'last'));
                    jump = length(select);
                    xt(select) = 2; % remember that this was a bout
                    boutcount(p(jmvpa):p(find(p < endi,1,'last'))) = 1;
                else
                    jump = 1;
                    x(p(jmvpa)) = 0;
                end
            else % bout does not fall within measurement
                jump = 1;
                if (length(p) > 1 && jmvpa > 2)
                    x(p(jmvpa)) = x(p(jmvpa-1));
                end
            end
            jmvpa = jmvpa + jump;
        end
        x(xt == 2) = 1;
        if any(xt == 1)
            x(xt == 1) = 0;
        end
        if boutClosed % only difference is that bouts are closed
            x = boutcount;
        end
    case 2 % MVPA based on percentage relative to start of bout
        xt = x;
        jmvpa = 1;
        while jmvpa <= length(p)
            endi = p(jmvpa)+boutduration;
            if endi <= length(x) % does bout fall without measurement?
                if (sum(x(p(jmvpa):endi)) > (boutduration*boutcriter))
                    xt(p(jmvpa):endi) = 2; % remember that this was a bout in r1t
                else
                    x(p(jmvpa)) = 0;
                end
            else % bout does not fall within measurement
                if (length(p) > 1 && jmvpa > 2)
                    x(p(jmvpa)) = x(p(jmvpa-1));
                end
            end
            jmvpa = jmvpa + 1;
        end
        x(xt == 2) = 1;
        boutcount = x;
    case 3 % bout metric simply looks at percentage of moving window that meets criterium
        x(isnan(x)) = 0; % ignore NA values in the unlikely event that there are any
        xt = x;
        % look for breaks larger than 1 minute
        lookforbreaks = rollCellFun(@mean, x, (60/ws3), 'fill', false);
        % insert negative numbers to prevent these minutes to be counted in bouts
        xt(lookforbreaks == 0) = -(60/ws3) * boutduration;
        % in this way there will not be bouts breaks lasting longer than 1 minute
        RM = rollCellFun(@mean, xt, boutduration, 'fill', false);
        p = find(RM > boutcriter);
        starti = round(boutduration/2);
        for gi = 1:boutduration
            inde = p-starti+(gi-1);
            xt(inde(inde > 0 & inde < length(xt))) = 2;
        end
        x(xt ~= 2) = 0;
        x(xt == 2) = 1;
        boutcount = x;
    case 4 % bout metric simply looks at percentage of moving window that meets criterium
        x(isnan(x)) = 0; % ignore NA values in the unlikely event that there are any
        xt = x;
        % look for breaks larger than 1 minute
        lookforbreaks = rollCellFun(@mean, x, (60/ws3), 'fill', true);
        % insert negative numbers to prevent these minutes to be counted in bouts
        xt(lookforbreaks == 0) = -(60/ws3) * boutduration;
        % in this way there will not be bouts breaks lasting longer than 1 minute
        RM = rollCellFun(@mean, xt, boutduration, 'fill', true);
        p = find(RM > boutcriter);
        starti = round(boutduration/2);
        % only consider windows that at least start and end with value that meets criterium
        tri = p-starti;
        kep = find(tri > 0 & tri < (length(x)-(boutduration-1)));
        if ~isempty(kep)
            tri = tri(kep);
        end
        p = p(x(tri) == 1 & x(tri+(boutduration-1)) == 1);
        % now mark all epochs that are covered by the remaining windows
        for gi = 1:boutduration
            inde = p-starti+(gi-1);
            xt(inde(inde > 0 & inde < length(xt))) = 2;
        end
        x(xt ~= 2) = 0;
        x(xt == 2) = 1;
        boutcount = x;
end