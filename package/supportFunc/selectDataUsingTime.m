function [x, t] = selectDataUsingTime(X, T, startDate, endDate, varargin)

if nargin > 4
    
    % Initialize the varargin parser
    p = inputParser;
    addParameter(p, 'select', 'all', ...
        @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
        );
    % Parse the variable arguments
    parse(p,varargin{:});
    
    % Select only week or weekend days
    switch p.Results.select
        case 'week'
            select = weekday(T) >= 2 & weekday(T) <= 6; % Monday (2) to Friday (6)
        case 'weekend'
            select = weekday(T) == 1 | weekday(T) == 7; % Sunday (1) or Saturday (7)
        otherwise
            select = true(size(T));
    end
else
    select = true(size(T));
end

idx = T >= startDate & T < endDate & select;
t = T(idx);

if sum(size(idx) == size(X)) == 2
    x = X(idx);
else
    x = X;
    t = T;
end