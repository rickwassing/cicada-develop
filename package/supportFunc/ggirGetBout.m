function boutcount = ggirGetBout(x, boutduration, varargin)

% force 'x' to be a double
x = double(x);

% Initialize the varargin parser
idxMVPA = inputParser;
%
addParameter(idxMVPA, 'boutcriter', 0.8, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonnan', 'scalar', '>', 0, '<=', 1}) ...
    );
addParameter(idxMVPA, 'boutClosed', false, ...
    @(x) validateattributes(x, {'logical'}, {'nonempty', 'nonnan', 'scalar'}) ...
    );
addParameter(idxMVPA, 'boutMetric', 1, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonnan', 'scalar', 'integer','>=' , 1, '<=', 6}) ...
    );
addParameter(idxMVPA, 'ws3', 5, ...
    @(x) validateattributes(x, {'numeric'}, {'nonempty', 'nonnan', 'scalar', 'integer'}) ...
    );
% Parse the variable arguments
parse(idxMVPA,varargin{:});

boutcriter = idxMVPA.Results.boutcriter;
boutClosed = idxMVPA.Results.boutClosed;
boutMetric = idxMVPA.Results.boutMetric;
epoch      = idxMVPA.Results.ws3;

idxMVPA = find(x == 1); % p are the indices for which the intensity criteria are met

switch boutMetric
    case 1
        xt = x;
        boutcount = zeros(length(x), 1); % initialize zeros as long as there are epochs in the timewindow
        idxStart = 1; % index for going stepwise through vector p
        while idxStart <= length(idxMVPA) % go through all epochs that are possibly part of a bout
            idxEnd = idxMVPA(idxStart)+boutduration;
            if idxEnd <= length(x) % bout falls within recording
                if sum(x(idxMVPA(idxStart):idxEnd)) > boutduration*boutcriter
                    while sum(x(idxMVPA(idxStart):idxEnd)) > (idxEnd-idxMVPA(idxStart))*boutcriter && idxEnd < length(x)
                        idxEnd = idxEnd + 1;
                    end
                    select = idxMVPA(idxStart:find(idxMVPA < idxEnd, 1, 'last'));
                    jump = length(select);
                    xt(select) = 2; % remember that this was a bout
                    boutcount(idxMVPA(idxStart):idxMVPA(find(idxMVPA < idxEnd, 1, 'last'))) = 1;
                else
                    jump = 1;
                    x(idxMVPA(idxStart)) = 0;
                end
            else % bout does not fall within recording
                jump = 1;
                if (length(idxMVPA) > 1 && idxStart > 2)
                    x(idxMVPA(idxStart)) = x(idxMVPA(idxStart-1));
                end
            end
            idxStart = idxStart + jump;
        end
        x(xt == 2) = 1;
        if any(xt == 1)
            x(xt == 1) = 0;
        end
        if boutClosed % only difference is that bouts are closed
            x = boutcount;
        end
    case 2 % MVPA based on percentage relative to start of bout
        xt = x;
        idxStart = 1;
        while idxStart <= length(idxMVPA)
            idxEnd = idxMVPA(idxStart)+boutduration;
            if idxEnd <= length(x) % bout falls wihtin recording
                if (sum(x(idxMVPA(idxStart):idxEnd)) > (boutduration*boutcriter))
                    xt(idxMVPA(idxStart):idxEnd) = 2; % remember that this was a bout
                else
                    x(idxMVPA(idxStart)) = 0;
                end
            else % bout does not fall within recording
                if (length(idxMVPA) > 1 && idxStart > 2)
                    x(idxMVPA(idxStart)) = x(idxMVPA(idxStart-1));
                end
            end
            idxStart = idxStart + 1;
        end
        x(xt == 2) = 1;
        boutcount = x;
    case 3 % bout metric simply looks at percentage of moving window that meets criterium
        x(isnan(x)) = 0; % ignore NA values in the unlikely event that there are any
        xt = x;
        % look for breaks larger than 1 minute
        lookforbreaks = rollCellFun(@mean, x, (60/epoch), 'fill', false);
        % insert negative numbers to prevent these minutes to be counted in bouts
        xt(lookforbreaks == 0) = -(60/epoch) * boutduration;
        % in this way there will not be bouts breaks lasting longer than 1 minute
        RM = rollCellFun(@mean, xt, boutduration, 'fill', false);
        idxMVPA = find(RM > boutcriter);
        idxStart = round(boutduration/2);
        for gi = 1:boutduration
            idx = idxMVPA-idxStart+(gi-1);
            xt(idx(idx > 0 & idx < length(xt))) = 2;
        end
        x(xt ~= 2) = 0;
        x(xt == 2) = 1;
        boutcount = x;
    case 4 % bout metric simply looks at percentage of moving window that meets criterium
        x(isnan(x)) = 0; % ignore NA values in the unlikely event that there are any
        xt = x;
        % look for breaks larger than 1 minute
        lookforbreaks = rollCellFun(@mean, x, (60/epoch), 'fill', true);
        % insert negative numbers to prevent these minutes to be counted in bouts
        xt(lookforbreaks == 0) = -(60/epoch) * boutduration;
        % in this way there will not be bouts breaks lasting longer than 1 minute
        RM = rollCellFun(@mean, xt, boutduration, 'fill', true);
        idxMVPA = find(RM > boutcriter);
        idxStart = round(boutduration/2);
        % only consider windows that at least start and end with value that meets criterium
        tri = idxMVPA-idxStart;
        kep = find(tri > 0 & tri < (length(x)-(boutduration-1)));
        if ~isempty(kep)
            tri = tri(kep);
        end
        idxMVPA = idxMVPA(x(tri) == 1 & x(tri+(boutduration-1)) == 1);
        % now mark all epochs that are covered by the remaining windows
        for gi = 1:boutduration
            idx = idxMVPA-idxStart+(gi-1);
            xt(idx(idx > 0 & idx < length(xt))) = 2;
        end
        x(xt ~= 2) = 0;
        x(xt == 2) = 1;
        boutcount = x;
    case 6
      x(isnan(x)) = 0; % ignore NA values in the unlikely event that there are any
      xt = x;
      % look for breaks larger than 1 minute
      % Note: we do + 1 to make sure we look for breaks larger than but not equal to a minute,
      % this is critical when working with 1 minute epoch data
      lookforbreaks = rollCellFun(@mean, x, (60/epoch), 'fill', true);
      % insert negative numbers to prevent these minutes to be counted in bouts
      % in this way there will not be bouts breaks lasting longer than 1 minute
      xt(lookforbreaks == 0) = -boutduration;
      RM = rollCellFun(@mean, xt, boutduration, 'fill', true);
      p = find(RM >= boutcriter);
      half1 = floor(boutduration/2);
      half2 = boutduration - half1;
      % only consider windows that at least start and end with value that meets criterium
      p = [0, p, 0];
      if epoch > 60
          epochs2check = 1;
      else
          epochs2check = 60/epoch;
      end
      for ii = 1:epochs2check % only check the first and last minute of each bout
        % p are all epochs at the centre of the windows that meet the bout criteria
        % we want to check the start and end of sequence meets the 
        % threshold criteria
        edges = find(diff(p) ~= 1); 
        seq_start = p(edges + 1);
        zeros = find(seq_start == 0);
        if ~isempty(zeros)
            seq_start(zeros) = []; % remove the appended zero
        end
        seq_end = p(edges); % bout centre starts
        zeros = find(seq_end == 0);
        if ~isempty(zeros)
            seq_end(zeros) = [];
        end
        length_xt = length(xt);
        % ignore epochs at beginning and end of time time series
        seq_start = seq_start(seq_start > half1 & seq_start < length_xt - half2);
        seq_end = seq_end(seq_end > half1 & seq_end < length_xt - half2);
        % check half a bout left of sequence centre:
        if ~isempty(seq_start)
          for bi = seq_start
            if length_xt >= (bi - half1)
              if xt((bi - half1) + 1) ~= 1 % if it does not meet criteria then remove this p value
                p(p == bi) = [];
              end
            end
          end
        end
        % check half a bout right of sequence centre:
        if ~isempty(seq_end)
          for bi = seq_end
            if length_xt >= (bi - half2)
              if xt((bi + half2) - 1) ~= 1
                p(p == bi) = [];
              end
            end
          end
        end
      end
      p = p(p ~= 0);
      % now mark all epochs that are covered by the remaining windows
      for gi = 1:boutduration
        inde = p-half1+gi;
        xt(inde(inde > 0 & inde < length(xt))) = 2;
      end
      x(xt ~= 2) = 0;
      x(xt == 2) = 1;
      boutcount = x; % distinction not made anymore, but object kept to preserve output structure
      
end