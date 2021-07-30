function y = map(x, min_x, max_x, min_map, max_map, varargin)
if nargin < 6
    crop = false;
else
    crop = varargin{:};
end
y = ((x - min_x) ./ (max_x - min_x)) .* (max_map - min_map) + min_map;
if crop
    y(y < min_map) = min_map;
    y(y > max_map) = max_map;
end
end