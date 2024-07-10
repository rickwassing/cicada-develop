function [ACT] = cic_annotateActivityCounts(ACT, params)
% OAKLEY markup epochs with activity counts as sleep/wake 

% Arguments:
%   act   - Input data timeseries (can be ACCZ or ACT)
%   args1 - {5 x 1} Cell array of algorithm arguments
%           Algorithm -   'oakley'
%           Method -      'i'    (immobility) - DEFAULT 
%                         'sw'    (sleep/wake)
%                         'none' (no estimation)
%           Sensitivity - 'l'    (low)
%                         'm'    (medium)     - DEFAULT
%                         'h'    (high)
%           Snooze -      'on' - DEFAULT
%                         'off'
%           Time window - 5      (minutes)
%                         7      (minutes)
%                         10     (minutes)    - DEFAULT 
%   args2 - {DAYS x 8} Cell array of sleep consensus diary inputs:
%           {'Date', 'Bed time', 'Lights off', 'Latency', 'Wake times',...
%           'Wake duration', 'Wake time', 'Out of bed'};
%
%
% Copyright (c) 2011-2014 Bart te Lindert
%
% See also: Oakley NR. Validation with polysomnography of the Sleepwatch 
%           sleep/wake scoring algorithm used by the Actiwatch activity 
%           monitor system: Technical Report to Mini-Mitter Co., Inc., 1997.
%
%           te Lindert BHW; Van Someren EJW. Sleep estimates using
%           microelectromechanical systems (MEMS). SLEEP 2013;
%           36(5):781-789
% 
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification,
% are permitted provided that the following conditions are met:
%
%  - Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%  - Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%  - Neither the name of the Netherlands Institute for Neuroscience nor the names of its
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
% IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
% OF THE POSSIBILITY OF SUCH DAMAGE.

% GET SAMPLING PERIOD
times = ACT.metric.acceleration.counts.Time;
sampling = [15, 30, 60, 120];
[~, idx] = min(abs(sampling - mean(diff(times)*24*60*60)));
sampling = sampling(idx);
if abs(sampling - mean(diff(times)*24*60*60)) > 1
    error('>> CIC: Sampling rate of ''%.3f'' is not supported.', mean(diff(times)*24*60*60))
end

% GET THRESHOLD
% Input can be either a character l/m/h sensitivity or a numeric threshold
% convert sensitivity to threshold
if ischar(params.wakeThreshold)
    if strcmpi(params.wakeThreshold, 'low')
        thres = 80;
    elseif strcmpi(params.wakeThreshold, 'medium')
        thres = 40;
    elseif strcmpi(params.wakeThreshold, 'high')
        thres = 20;
    end
elseif isnumeric(params.wakeThreshold)
    thres = params.wakeThreshold;
end

%   0.5 for 2 minute epochs
if sampling == 15
    coeff = [(1/25), (1/25), (1/25), (1/25),...
             (1/5), (1/5), (1/5), (1/5), 4,...
             (1/5), (1/5), (1/5), (1/5),...
             (1/25), (1/25), (1/25), (1/25)];
    shift = 9;
elseif sampling == 30
    coeff = [(1/25), (1/25),...
             (1/5), (1/5), 2,...
             (1/5), (1/5),...
             (1/25), (1/25)];
    shift = 5;
elseif sampling == 60
    coeff = [(1/25), (1/5), 1, (1/5), (1/25)];
    shift = 3;
elseif sampling == 120
    coeff = [(1/5), 0.5, (1/5)];
    shift = 2;
else 
    errordlg('Epoch duration not supported', 'Error', 'modal');
    return
end

% score data using oakley's algorithm
% TODO, add ref...
filtCounts = filter(coeff, 1, ACT.metric.acceleration.counts.Data);

% shift data backwards to correct for filter shift
filtCounts = [filtCounts(shift:end); zeros(shift-1, 1)];

wake = filtCounts > thres;

% score epochs as MOBILE if counts >= 1
% An epoch is scored as MOBILE if the number of 
% activity counts recorded in that epoch is greater 
% than or equal to the epoch length in 15-second intervals. 
% For example,there are four 15-second intervals for a 
% 1-minute epoch length; hence, the activity value in a 1-min epoch 
% must be greater than, or equal to four to be scored as MOBILE.
% mobile = score > (sampling/15);

% -----
% Initialize an empty a timeseries object
ACT.analysis.annotate.acceleration = timeseries(zeros(length(times), 1), times, 'Name', 'annotateAcceleration');
ACT.analysis.annotate.acceleration.DataInfo.Units = 'a.u.';
ACT.analysis.annotate.acceleration.TimeInfo.Units = 'days';
ACT.analysis.annotate.acceleration.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.analysis.annotate.acceleration.TimeInfo.StartDate = '00-Jan-0000 00:00:00';

% ---------------------------------------------------------
% Save 'wake' as a timeseries in 'ACT.analysis.annotate'
ACT.analysis.annotate.acceleration.Data(wake) = 1;

% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'analysis');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Annotate the accelerometry data using OAKLEY''s function');
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Define the parameters');
ACT.history = char(ACT.history, sprintf('params.wakeThreshold = %i;', params.wakeThreshold));
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Call the annotation function');
ACT.history = char(ACT.history, 'ACT = cic_annotateCounts(ACT, params);');

end
