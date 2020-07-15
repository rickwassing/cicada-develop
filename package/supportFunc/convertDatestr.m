function str = convertDatestr(str, oldFormat, newFormat)
str = datestr(datenum(str, oldFormat), newFormat);
end % EOF