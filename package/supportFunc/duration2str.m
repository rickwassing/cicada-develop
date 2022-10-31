function str = duration2str(duration)

if isnumeric(duration)
    if isempty(duration) || isnan(duration)
        str = '-';
        return
    end
else
    if isempty(duration) || strcmpi(duration, 'n.a.') || strcmpi(duration, 'na') || strcmpi(duration, 'na.') || strcmpi(duration, 'NaN')
        str = '-';
        return
    else 
        duration = str2double(duration);
    end
end

DD = duration;
HH = (DD - floor(DD))*24;
DD = floor(DD);
MM = (HH - floor(HH))*60;
HH = floor(HH);
SS = (MM - floor(MM))*60;
MM = floor(MM);
MS = (SS - floor(SS))*1000;
SS = floor(SS);
MS = round(MS);
if MS > 999
    SS = SS+1;
    MS = MS-1000;
end
if SS > 59
    MM = MM+1;
    SS = SS-60;
end
if MM > 59
    HH = HH+1;
    MM = MM-60;
end
if HH > 24
    DD = DD+1;
    HH = HH-24;
end
str = {};
if DD ~= 0
    str = [str, {[num2str(DD), 'd']}];
end

% Return '#d' if (days is not zero) AND (hours AND minutes AND SECONDS are zero)
if DD ~= 0 && HH == 0 && MM == 0 && SS == 0
    str = strjoin(str);
    return
end

% Add the hours value to the string if 
% (1) hours is not zero OR if 
% days is not zero AND minutes is not zero OR
% days is not zero AND seconds is not zero
if HH ~= 0 || (DD ~= 0 && MM ~= 0) || (DD ~= 0 && SS ~= 0)
    str = [str, {[num2str(HH), 'h']}];
end

% then also add minutes and seconds
if MM > 0 || SS > 5
    str = [str, {[num2str(MM), 'm']}];
    str = [str, {[num2str(SS), 's']}];
else
    str = [str, {sprintf('%.3fs', SS+MS/1000)}];
end
str = strjoin(str);

end