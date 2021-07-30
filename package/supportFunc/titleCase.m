function str = titleCase(str)
str = regexprep(lower(str),'(\<[a-z])','${upper($1)}');
end