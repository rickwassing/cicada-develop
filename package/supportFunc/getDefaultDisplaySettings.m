function display = getDefaultDisplaySettings(data, display)

display.order = fieldnames(data);
display.order(strcmpi(display.order, 'acceleration')) = [];
            
for di = 1:length(display.order)
    if ~isfield(display, display.order{di})
        display.(display.order{di}) = struct();
        display.(display.order{di}).field = struct();
        display.(display.order{di}).rowspan = 1;
        display.(display.order{di}).show = 1;
        switch display.order{di}
            case 'light'
                display.(display.order{di}).range = [0, 20000];
                display.(display.order{di}).log = 1;
            case 'temperature'
                display.(display.order{di}).range = [0, 40];
                display.(display.order{di}).log = 0;
            case 'bodyposition'
                display.(display.order{di}).range = [0, 1];
                display.(display.order{di}).log = 0;
            case 'heart'
                display.(display.order{di}).range = [0, 1];
                display.(display.order{di}).log = 0;
            case 'breathing'
                display.(display.order{di}).range = [0, 1];
                display.(display.order{di}).log = 0;
            case 'blood'
                display.(display.order{di}).range = [0, 1];
                display.(display.order{di}).log = 0;
        end
    end
    fnames = flipud(fieldnames(data.(display.order{di})));
    for fi = 1:length(fnames)
        if ~isfield(display.(display.order{di}).field, fnames{fi})
            display.(display.order{di}).field.(fnames{fi}).show = 1;
            display.(display.order{di}).field.(fnames{fi}).clr = mount_colororder(mod(fi-1, 9)+1);
        end
    end
end


end