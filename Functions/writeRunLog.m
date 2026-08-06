function writeRunLog(outDir, scriptName, details)
%WRITERUNLOG Write a plain-text run log for reproducibility.
    logPath = fullfile(outDir, sprintf('%s_run_log.txt', scriptName));
    fid = fopen(logPath, 'w');
    if fid < 0
        warning('writeRunLog:WriteFailed', 'Could not write run log to %s', logPath);
        return;
    end

    fprintf(fid, 'Script: %s\n', scriptName);
    fprintf(fid, 'Run time: %s\n', char(datetime('now')));
    fprintf(fid, 'MATLAB: %s\n', version);
    fprintf(fid, 'RNG seed: 1\n\n');

    fields = fieldnames(details);
    for i = 1:numel(fields)
        val = details.(fields{i});
        if iscell(val)
            if numel(val) == 1 && iscell(val{1})
                val = val{1};
            end
            val = strjoin(string(val(:)), ', ');
        elseif isstring(val) || ischar(val)
            val = char(string(val));
        else
            val = evalc('disp(val)');
            val = strtrim(val);
        end
        fprintf(fid, '%s: %s\n', fields{i}, val);
    end

    fclose(fid);
end
