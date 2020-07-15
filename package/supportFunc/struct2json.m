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

function struct2json(S, jsonFileName)
if nargin == 2
    fid = fopen(jsonFileName,'w');
else
    fid = 0;
end
sep = ',';
for i = 1:length(S)
    if i == length(S)
        sep = '';
    end
    fprintf('{\n');
    if fid ~= 0; fprintf(fid,'{\n'); end
    writeElement(fid, S(i), fieldnames(S(i)), '');
    fprintf('}%s\n', sep);
    if fid ~= 0; fprintf(fid,'}%s\n', sep); end
end
if fid ~= 0; fclose(fid); end
end

function writeElement(fid, S, fnames, tabs)

tabs = sprintf('%s\t', tabs);

sep_j = ',';
for j = 1:length(fnames)
    if j == length(fnames)
        sep_j = '';
    end
    if isstruct(S.(fnames{j}))
        if length(S.(fnames{j})) == 1
            fprintf('%s"%s": {\n', tabs, fnames{j});
            if fid ~= 0; fprintf(fid,'%s"%s": {\n', tabs, fnames{j}); end
            writeElement(fid, S.(fnames{j}), fieldnames(S.(fnames{j})), tabs)
            fprintf('%s}%s\n', tabs, sep_j);
            if fid ~= 0; fprintf(fid,'%s}%s\n', tabs, sep_j); end
        else
            fprintf('%s"%s": [\n', tabs, fnames{j});
            if fid ~= 0; fprintf(fid,'%s"%s": [\n', tabs, fnames{j}); end
            tabs = sprintf('%s\t', tabs);
            sep_k = ',';
            for k = 1:length(S.(fnames{j}))
                if k == length(S.(fnames{j}))
                    sep_k = '';
                end
                fprintf('%s{\n', tabs);
                if fid ~= 0; fprintf(fid,'%s{\n', tabs); end
                writeElement(fid, S.(fnames{j})(k), fieldnames(S.(fnames{j})(k)), tabs)
                fprintf('%s}%s\n', tabs, sep_k);
                if fid ~= 0; fprintf(fid,'%s}%s\n', tabs, sep_k); end
            end
            tabs = sprintf('%s\b', tabs);
            fprintf('%s]%s\n', tabs, sep_j);
            if fid ~= 0; fprintf(fid,'%s]%s\n', tabs, sep_j); end
        end
    else
        if isempty(S.(fnames{j}))
            fprintf('%s"%s": null%s\n', tabs, fnames{j}, sep_j);
            if fid ~= 0; fprintf(fid, '%s"%s": null%s\n', tabs, fnames{j}, sep_j); end
        elseif length(S.(fnames{j})) == 1 || ischar(S.(fnames{j}))
            val = S.(fnames{j});
            if iscell(val)
                val = val{:};
            end
            if isnumeric(val)
                fprintf('%s"%s": %g%s\n', tabs, fnames{j}, val, sep_j);
                if fid ~= 0; fprintf(fid, '%s"%s": %g%s\n', tabs, fnames{j}, val, sep_j); end
            else
                fprintf('%s"%s": "%s"%s\n', tabs, fnames{j}, val, sep_j);
                if fid ~= 0; fprintf(fid, '%s"%s": "%s"%s\n', tabs, fnames{j}, val, sep_j); end
            end
        else
            fprintf('%s"%s": [\n', tabs, fnames{j});
            if fid ~= 0; fprintf(fid, '%s"%s": [\n', tabs, fnames{j}); end
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
                    fprintf('%s\t%g%s\n', tabs, val, sep_k);
                    if fid ~= 0; fprintf(fid, '%s\t%g%s\n', tabs, val, sep_k); end
                elseif isempty(val)
                    fprintf('%s\tnull%s\n', tabs, sep_k);
                    if fid ~= 0; fprintf(fid, '%s\tnull%s\n', tabs, sep_k); end
                else
                    fprintf('%s\t"%s"%s\n', tabs, val, sep_k);
                    if fid ~= 0; fprintf(fid, '%s\t"%s"%s\n', tabs, val, sep_k); end
                end
            end
            fprintf('%s]%s\n', tabs, sep_j);
            if fid ~= 0; fprintf(fid, '%s]%s\n', tabs, sep_j); end
        end
    end
end
end