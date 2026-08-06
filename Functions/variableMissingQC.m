function qc = variableMissingQC(T, dataCols)
%VARIABLEMISSINGQC Per-column missing-value summary for QC tables.
%
%   qc columns: Variable, SourceColumn, N_Total, N_Missing, N_Usable

    nRows = height(T);
    nVars = numel(dataCols);
    qc = table('Size', [nVars 5], ...
        'VariableTypes', {'string', 'string', 'double', 'double', 'double'}, ...
        'VariableNames', {'Variable', 'SourceColumn', 'N_Total', 'N_Missing', 'N_Usable'});

    for j = 1:nVars
        colName = dataCols{j};
        info = parseColumnLabel(colName);
        col = getTableColumn(T, colName);
        y = toNumericFlexible(col, colName);
        nUsable = sum(isfinite(y));
        qc.Variable(j) = info.displayLabel;
        qc.SourceColumn(j) = string(colName);
        qc.N_Total(j) = nRows;
        qc.N_Missing(j) = nRows - nUsable;
        qc.N_Usable(j) = nUsable;
    end
end
