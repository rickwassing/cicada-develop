function handles = mount_sleepClock(app, parent, varargin)

r = 11; % Radius of the clock
w = 5;  % Width of the clock

% Initialize the varargin parser
p = inputParser;
% Add parameters
addParameter(p, 'Tag', 'sleepClock', ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
    );
addParameter(p, 'SleepWindowAct', []);
addParameter(p, 'SleepPeriodAct', []);
addParameter(p, 'AwakeningAct', []);
addParameter(p, 'SleepWindowDiary', []);
addParameter(p, 'SleepPeriodDiary', []);
addParameter(p, 'AwakeningDiary', []);
% Parse the variable arguments
parse(p,varargin{:});

Component = plot_clockface(parent);
Component.Tag = p.Results.Tag;

% Check if we have both the Obj and Sbj, if so, plot on 'outer' and 'inner' radius, if not, plot Obj in 'middle' radius
if isempty(p.Results.SleepWindowDiary)
    plotRad = 'middle';
else
    plotRad = 'out';
end

if ~isempty(p.Results.SleepWindowAct);  handles.Clock.SleepWindowAct  = plot_arc(parent, p.Results.SleepWindowAct(1), p.Results.SleepWindowAct(2), plotRad, [208, 92, 227]/255); end
if ~isempty(p.Results.SleepPeriodAct); handles.Clock.SleepPeriodAct = plot_arc(parent, p.Results.SleepPeriodAct(1), p.Results.SleepPeriodAct(2), plotRad, [0, 60, 143]/255); end
if ~isempty(p.Results.AwakeningAct)
    for oi = 1:size(p.Results.AwakeningAct, 1)
        handles.Clock.AwakeningAct(oi).h  = plot_arc(parent, p.Results.AwakeningAct(oi, 1), p.Results.AwakeningAct(oi, 2), plotRad, [94, 146, 243]/255);
    end
end

if ~isempty(p.Results.SleepWindowDiary);  handles.Clock.SleepWindowDiary  = plot_arc(parent, p.Results.SleepWindowDiary(1), p.Results.SleepWindowDiary(2), 'in', [255, 121, 97]/255); end
if ~isempty(p.Results.SleepPeriodDiary); handles.Clock.SleepPeriodDiary = plot_arc(parent, p.Results.SleepPeriodDiary(1), p.Results.SleepPeriodDiary(2), 'in', [0, 86, 98]/255); end
if ~isempty(p.Results.AwakeningDiary)
    for oi = 1:size(p.Results.AwakeningDiary, 1)
        handles.Clock.AwakeningDiary(oi).h  = plot_arc(parent, p.Results.AwakeningDiary(oi, 1), p.Results.AwakeningDiary(oi, 2), 'in', [79, 179, 191]/255);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NESTED FUNCTIONS
    function handle = plot_clockface(ax)
        ax.XLim = [-r, r];
        ax.YLim = [-r, r];
        
        t = map(0:1/12:12, 0, 12, 2.5*pi, 0.5*pi);
        x = [r*cos(t), (r-w)*cos(t)];
        y = [r*sin(t), (r-w)*sin(t)];
        
        handle = patch(ax, 'XData', x, 'YData', y, ...
            'FaceColor', [0.8, 0.8, 0.8], ...
            'LineStyle', 'none');
        
        cnt = 0;
        for h = 0:11
            for m = 0:10:50
                if m == 0
                    lWidth = 2;
                else
                    lWidth = 0.5;
                end
                cnt = cnt+1;
                plot(ax, ...
                    [0, r*cos(map(h+m/60, 0, 12, 2.5*pi, 0.5*pi))], ...
                    [0, r*sin(map(h+m/60, 0, 12, 2.5*pi, 0.5*pi))], ...
                    'Color', 'w', ...
                    'LineStyle' , '-', ...
                    'LineWidth', lWidth);
            end
        end
    end

    function h = plot_arc(ax, startDate, endDate, track, clr)
        skip = false;
        t    = mod(startDate, 1)*24;
        t(2) = mod(endDate, 1)*24;
        if t(1) < t(2)
            t = t(1):1/60:t(2);
        elseif t(1) > t(2)
            t = [t(1):1/60:24, 1/60:1/60:t(2)];
        elseif t(1) == t(2)
            t = 0;
        else
            h = [];
            skip = true;
        end
        if ~skip
            t = map(mod(t, 12), 0, 12, 2.5*pi, 0.5*pi);
            switch track
                case 'out'
                    subtr = 0;
                    x = [(r-subtr)*cos(t), fliplr((r-subtr-w/2+w/100)*cos(t))];
                    y = [(r-subtr)*sin(t), fliplr((r-subtr-w/2+w/100)*sin(t))];
                case 'in'
                    subtr = w/2;
                    x = [(r-subtr-w/100)*cos(t), fliplr((r-subtr-w/2)*cos(t))];
                    y = [(r-subtr-w/100)*sin(t), fliplr((r-subtr-w/2)*sin(t))];
                case 'middle'
                    subtr = w/4;
                    x = [(r-subtr)*cos(t), fliplr((r-subtr-w/2+w/100)*cos(t))];
                    y = [(r-subtr)*sin(t), fliplr((r-subtr-w/2+w/100)*sin(t))];
            end
            
            h = patch(ax, 'XData', x, 'YData', y, ...
                'FaceColor', clr, ...
                'LineStyle', 'none');
        end
    end

end %EOF
