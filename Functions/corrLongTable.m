function Tbl = corrLongTable(labels, R, P, N, minN)
%CORRLONGTABLE Long-format Spearman correlation table.

    if nargin < 5 || isempty(minN)
        minN = 6;
    end

    labels = string(labels(:));
    nVars = numel(labels);
    rows = cell(0, 6);

    for i = 1:nVars
        for j = i + 1:nVars
            nPair = N(i, j);
            rho = R(i, j);
            pval = P(i, j);

            if nPair < minN || isnan(rho)
                status = "InsufficientN";
            else
                status = "OK";
            end

            rows(end + 1, :) = {labels(i), labels(j), nPair, rho, pval, status}; %#ok<AGROW>
        end
    end

    if isempty(rows)
        Tbl = table(string.empty(0, 1), string.empty(0, 1), zeros(0, 1), ...
            zeros(0, 1), zeros(0, 1), string.empty(0, 1), ...
            'VariableNames', {'Var1', 'Var2', 'N_pairwise', 'SpearmanRho', 'pValue', 'Status'});
    else
        Tbl = cell2table(rows, 'VariableNames', ...
            {'Var1', 'Var2', 'N_pairwise', 'SpearmanRho', 'pValue', 'Status'});
    end
end
