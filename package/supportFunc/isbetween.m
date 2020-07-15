function b = isbetween(x, lo, hi)

if isempty(x); b = false; return; end
b = x >= lo & x <= hi;

end