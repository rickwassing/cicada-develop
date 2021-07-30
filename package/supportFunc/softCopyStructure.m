function a = softCopyStructure(a, b)
% Copies fields from 'b' to 'a' only if the field does not exist in 'a'
fnames = fieldnames(b);
for fi = 1:length(fnames)
    if isstruct(b.(fnames{fi}))
        if ~isfield(a, fnames{fi})
            a.(fnames{fi}) = struct();
        end
        a.(fnames{fi}) = softCopyStructure(a.(fnames{fi}), b.(fnames{fi}));
    else
        if ~isfield(a, fnames{fi})
            a.(fnames{fi}) = b.(fnames{fi});
        end
    end
end

end
