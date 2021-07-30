function ACT = cic_updatePipe(ACT, step)

pipeline = {'load', 'preproc', 'analysis', 'statistics'};
idx = find(strcmpi(step, pipeline));

% Update the pipe
if isempty(ACT.pipe)
    ACT.pipe = {step};
elseif strcmpi(ACT.pipe{end}, 'load') && idx > 1
    ACT.pipe = [ACT.pipe; {step}];
elseif strcmpi(ACT.pipe{end}, 'preproc') && idx > 2
    ACT.pipe = [ACT.pipe; {step}];
elseif strcmpi(ACT.pipe{end}, 'analysis') && idx > 3
    ACT.pipe = [ACT.pipe; {step}];
elseif ~strcmpi(ACT.pipe{end}, 'statistics') && idx == 4
    ACT.pipe = [ACT.pipe; {step}];
end

end % EOF
