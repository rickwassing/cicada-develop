function X = removeOffsetGain(X,offset,scale)

if islogical(offset) && offset
    offset = repmat(mean(X),size(X,1),1);
elseif islogical(offset) && ~offset
    offset = zeros(size(X));
else
    n = size(X,1)./size(offset,1);
    m = size(X,2)./size(offset,2);
    offset = repmat(offset,n,m);
end
if islogical(scale) && scale
    scale = repmat(std(X),size(X,1),1);
elseif islogical(scale) && ~scale
    scale = repmat(rms(X),size(X,1),1);
else
    n = size(X,1)./size(scale,1);
    m = size(X,2)./size(scale,2);
    scale = repmat(scale,n,m);
end

X = (X - offset) ./ scale;