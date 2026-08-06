function col = getTableColumn(T, colName)
%GETTABLECOLUMN Return one table column by exact VariableNames match.
%
%   Works with headers containing spaces, units, or special characters
%   (e.g. "Cortical Stiffness (pN/nm)") when VariableNamingRule is preserve.

    if istable(colName) || (iscell(colName) && numel(colName) == 1)
        colName = colName{1};
    end
    colName = char(string(colName));

    varNames = T.Properties.VariableNames;
    idx = find(strcmp(varNames, colName), 1);

    if isempty(idx)
        error('getTableColumn:NotFound', ...
            'Column "%s" was not found in the table.', colName);
    end

    col = T{:, idx};
end
