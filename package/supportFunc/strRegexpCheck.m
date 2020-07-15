function bool = strRegexpCheck(str, exp)
if ~iscell(str)
    str = {str};
end
bool = cellfun(@(x) ~isempty(x), regexp(str, exp));