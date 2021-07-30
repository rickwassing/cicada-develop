% saves the values in the structure 'data' to a file in JSON format.
%
% Example:
%     data.name = 'chair';
%     data.color = 'pink';
%     data.metrics.height = 0.3;
%     data.metrics.width = 1.3;
%     saveJSONfile(data, 'out.json');
%
% Output 'out.json':
% {
% 	"name" : "chair",
% 	"color" : "pink",
% 	"metrics" : {
% 		"height" : 0.3,
% 		"width" : 1.3
% 		}
% 	}
%

function errorMsg = struct2json(S, jsonFileName, verbose)
if nargin < 3
    verbose = false;
end
if nargin == 2
    [fid, errorMsg] = fopen(jsonFileName, 'w');
    if fid == -1
        return
    end
else
    fid = -1;
    verbose = true;
end
sep = ',';
for i = 1:length(S)
    if i == length(S)
        sep = '';
    end
    if verbose;      fprintf('{\n'); end
    if fid ~= -1; fprintf(fid,'{\n'); end
    writeElement(fid, S(i), fieldnames(S(i)), '', verbose);
    if verbose;      fprintf('}%s\n', sep); end
    if fid ~= -1; fprintf(fid,'}%s\n', sep); end
end
if fid ~= -1; fclose(fid); end
end

function writeElement(fid, S, fnames, tabs, verbose)

tabs = sprintf('%s\t', tabs);

sep_j = ',';
for j = 1:length(fnames)
    if j == length(fnames)
        sep_j = '';
    end
    if isstruct(S.(fnames{j}))
        if length(S.(fnames{j})) == 1
            if verbose;       fprintf('%s"%s": {\n', tabs, fnames{j}); end
            if fid ~= -1; fprintf(fid, '%s"%s": {\n', tabs, fnames{j}); end
            writeElement(fid, S.(fnames{j}), fieldnames(S.(fnames{j})), tabs, verbose)
            if verbose;       fprintf('%s}%s\n', tabs, sep_j); end
            if fid ~= -1; fprintf(fid, '%s}%s\n', tabs, sep_j); end
        else
            if verbose;       fprintf('%s"%s": [\n', tabs, fnames{j}); end
            if fid ~= -1; fprintf(fid, '%s"%s": [\n', tabs, fnames{j}); end
            tabs = sprintf('%s\t', tabs);
            sep_k = ',';
            for k = 1:length(S.(fnames{j}))
                if k == length(S.(fnames{j}))
                    sep_k = '';
                end
                if verbose;       fprintf('%s{\n', tabs); end
                if fid ~= -1; fprintf(fid, '%s{\n', tabs); end
                writeElement(fid, S.(fnames{j})(k), fieldnames(S.(fnames{j})(k)), tabs, verbose)
                if verbose;       fprintf('%s}%s\n', tabs, sep_k); end
                if fid ~= -1; fprintf(fid, '%s}%s\n', tabs, sep_k); end
            end
            tabs = sprintf('%s\b', tabs);
            if verbose;       fprintf('%s]%s\n', tabs, sep_j); end
            if fid ~= -1; fprintf(fid, '%s]%s\n', tabs, sep_j); end
        end
    else
        if isempty(S.(fnames{j}))
            if verbose;       fprintf('%s"%s": null%s\n', tabs, fnames{j}, sep_j); end
            if fid ~= -1; fprintf(fid, '%s"%s": null%s\n', tabs, fnames{j}, sep_j); end
        elseif length(S.(fnames{j})) == 1 || ischar(S.(fnames{j}))
            val = S.(fnames{j});
            if iscell(val)
                val = val{:};
            end
            if isnumeric(val)
                if verbose;       fprintf('%s"%s": %g%s\n', tabs, fnames{j}, val, sep_j); end
                if fid ~= -1; fprintf(fid, '%s"%s": %g%s\n', tabs, fnames{j}, val, sep_j); end
            else
                if verbose;       fprintf('%s"%s": "%s"%s\n', tabs, fnames{j}, val, sep_j); end
                if fid ~= -1; fprintf(fid, '%s"%s": "%s"%s\n', tabs, fnames{j}, val, sep_j); end
            end
        else
            if verbose;       fprintf('%s"%s": [\n', tabs, fnames{j}); end
            if fid ~= -1; fprintf(fid, '%s"%s": [\n', tabs, fnames{j}); end
            sep_k = ',';
            for k = 1:length(S.(fnames{j}))
                if k == length(S.(fnames{j}))
                    sep_k = '';
                end
                if iscell(S.(fnames{j})(k))
                    val = S.(fnames{j}){k};
                else
                    val = S.(fnames{j})(k);
                end
                if isnumeric(val)
                    if verbose;       fprintf('%s\t%g%s\n', tabs, val, sep_k); end
                    if fid ~= -1; fprintf(fid, '%s\t%g%s\n', tabs, val, sep_k); end
                elseif isempty(val)
                    if verbose;       fprintf('%s\tnull%s\n', tabs, sep_k); end
                    if fid ~= -1; fprintf(fid, '%s\tnull%s\n', tabs, sep_k); end
                else
                    if verbose;       fprintf('%s\t"%s"%s\n', tabs, val, sep_k); end
                    if fid ~= -1; fprintf(fid, '%s\t"%s"%s\n', tabs, val, sep_k); end
                end
            end
            if verbose;       fprintf('%s]%s\n', tabs, sep_j); end
            if fid ~= -1; fprintf(fid, '%s]%s\n', tabs, sep_j); end
        end
    end
end
end
