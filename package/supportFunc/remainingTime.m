% REMAININGTIME Display the progress and remaining time for loops
function rt = remainingTime(N, varargin)

if nargin < 2
    print2screen = true;
else
    print2screen = varargin{:};
end

% Create persistent variable
persistent T;

% If the persistent variable is just initialized, it's empty so define its variables
if isempty(T)
    T = struct();
    T.startTime = now;
    T.cnt = 0;
    T.pct = 0;
    T.str = '';
    if print2screen
        fprintf('Start date: %s - ', datestr(T.startTime, 'dd/mm/yyyy HH:MM:SS'))
    end
end

% Up the counter
T.cnt = T.cnt + 1;

% Calculate percentage
% If 'N' is less than 1, its value is a percentage, so convert it to total number
if N < 1
    N = round(T.cnt/N);
end
if floor(100*(T.cnt/N)) == T.pct
    return
end 
T.pct = floor(100*(T.cnt/N));

% Calculate remaining time as a datestr 'HH:MM:SS'
rt = ((now - T.startTime)/T.cnt)*(N-T.cnt);
HH = floor(rt*24);
MM = floor((rt*24-HH)*60);
SS = floor(((rt*24-HH)*60-MM)*60);
rt = [num2str(HH), 'h ' num2str(MM), 'm ', num2str(SS), 's'];

% Print to screen
if print2screen
    fprintf([repmat('\b', 1, length(T.str)) '(%.0f%%) %s '], T.pct, rt)
end

% Update the string in 'T'
T.str = sprintf('(%.0f%%) %s ', T.pct, rt);

% If counter is equal to N, we're done
if T.cnt == N
    fprintf('- Finished in %s\n', datestr(now-T.startTime, 'HH:MM:SS'))
    T = now;
end

end % EOF
