function y = map(x, min_x, max_x, min_map, max_map, varargin)
if nargin < 6
    crop = false;
else
    crop = varargin{:};
end
if x > max_x; x = max_x; end
if x < min_x; x = min_x; end
y = ((x - min_x) ./ (max_x - min_x)) .* (max_map - min_map) + min_map;
if crop
    y(y < min_map) = min_map;
    y(y > max_map) = max_map;
end
end