function v = asrow(v)
if ~(any(size(v) == 1))
    error('Input needs to be a vector')
end
if iscolumn(v)
    v = v';
end
end