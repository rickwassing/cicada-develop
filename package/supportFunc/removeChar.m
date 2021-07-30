function lbls = removeChar(lbls,ch)

if iscell(lbls)
    for c = 1:length(ch)
        lbls = cellfun(@(x) strjoin(strsplit(x,ch{c}),''),lbls,'UniformOutput',false);
    end
else
    for c = 1:length(ch)
        lbls = strjoin(strsplit(lbls,ch{c}),'');
    end
end
end