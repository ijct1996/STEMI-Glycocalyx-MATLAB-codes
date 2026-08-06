function [filePath, T] = loadSTEMITable()
%LOADSTEMITABLE Prompt for a STEMI Excel file and read it as a table.
    [fn, fp] = uigetfile({'*.xlsx;*.xls', 'Excel files (*.xlsx, *.xls)'}, ...
        'Select STEMI Excel file');
    if isequal(fn, 0)
        error('loadSTEMITable:Cancelled', 'STEMI file selection cancelled.');
    end

    filePath = fullfile(fp, fn);
    T = readtable(filePath, 'VariableNamingRule', 'preserve');

    if isempty(T) || width(T) == 0
        error('loadSTEMITable:EmptyFile', 'Selected STEMI file is empty or unreadable.');
    end

    fprintf('Loaded STEMI file: %s (%d rows, %d columns)\n', fn, height(T), width(T));
end
