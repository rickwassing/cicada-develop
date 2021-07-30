function str = duration2str(duration)

if isempty(duration) || isnan(duration)
    str = '-';
    return
end

days = floor(duration);
hours = floor((duration-days)*24);
minutes = round((((duration-days)*24)-hours)*60);
while minutes >= 60
    hours = hours+1;
    minutes = minutes-60;
end
while hours >= 24
    days = days+1;
    hours = hours-24;
end
str = {};
if days ~= 0
    str = [str, {[num2str(days), 'd']}];
end

% Return '#d' if days is not zero and hours and minutes are zero
if days ~= 0 && hours == 0 && minutes == 0
    str = strjoin(str);
    return
end

% Add the hours value to the string if it's not zero or if days is not zero AND minutes is not zero
if hours ~= 0 || (days ~= 0 && minutes ~= 0)
    str = [str, {[num2str(hours), 'h']}];
end

str = [str, {[num2str(minutes), 'm']}];

str = strjoin(str);

end