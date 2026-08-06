function [Pbh, bhTbl] = bhAdjustSymmetricP(P, labels)
%BHADJUSTSYMMETRICP BH/FDR correction for upper triangle of a symmetric matrix.

    Pbh = NaN(size(P));
    if isempty(P) || isempty(labels)
        bhTbl = table(string.empty(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), ...
            zeros(0, 1), zeros(0, 1), false(0, 1), ...
            'VariableNames', {'VariableOrTest', 'RawP', 'Rank', 'm', 'BH_Raw', 'BH_Adjusted', 'Significant_BH'});
        return;
    end

    labels = string(labels(:));
    n = min(size(P, 1), size(P, 2));
    if numel(labels) ~= n
        labels = string((1:n)');
    end

    upperMask = triu(true(n), 1);
    [ii, jj] = find(upperMask);
    pRaw = P(sub2ind(size(P), ii, jj));
    pairLabels = labels(ii) + " vs " + labels(jj);

    [bhTbl, pBH] = makeBHWorkflowTable(pairLabels, pRaw);

    for k = 1:numel(ii)
        Pbh(ii(k), jj(k)) = pBH(k);
        Pbh(jj(k), ii(k)) = pBH(k);
    end
    Pbh(1:n + 1:n * n) = 0;
end
