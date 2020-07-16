function display = updateDisplaySettings(data, display)

dtypes = fieldnames(data);
dtypes(strcmpi(dtypes, 'acceleration')) = [];
for di = 1:length(dtypes)
    if ~ismember(dtypes{di}, display.order)
        display.order = [display.order, dtypes(di)];
        display.(dtypes{di}).field = struct();
        display.(dtypes{di}).rowspan = 1;
        display.(dtypes{di}).show = 1;
        switch dtypes{di}
            case 'light'
                display.(dtypes{di}).range = [0, 20000];
                display.(dtypes{di}).log = 1;
            case 'temperature'
                display.(dtypes{di}).range = [0, 40];
                display.(dtypes{di}).log = 0;
            case 'bodyposition'
                display.(dtypes{di}).range = [0, 1];
                display.(dtypes{di}).log = 0;
            case 'heart'
                display.(dtypes{di}).range = [0, 1];
                display.(dtypes{di}).log = 0;
            case 'breathing'
                display.(dtypes{di}).range = [0, 1];
                display.(dtypes{di}).log = 0;
            case 'blood'
                display.(dtypes{di}).range = [0, 1];
                display.(dtypes{di}).log = 0;
            otherwise
                display.(dtypes{di}).range = [0, 1];
                display.(dtypes{di}).log = 0;
        end
    end
    fnames = fieldnames(data.(dtypes{di}));
    for fi = 1:length(fnames)
        if ~isfield(display.(dtypes{di}).field, fnames{fi})
            display.(dtypes{di}).field.(fnames{fi}).show = 1;
            display.(dtypes{di}).field.(fnames{fi}).clr = mount_colororder(mod(fi-1, 9)+1);
        end
    end
end


end