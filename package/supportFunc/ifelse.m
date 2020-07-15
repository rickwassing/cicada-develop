% Shorthand implementation of a simple if-else statement
function res = ifelse(bool, resTrue, resFalse)
if bool; res = resTrue; else; res = resFalse; end
end