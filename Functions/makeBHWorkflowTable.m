function [bhTbl, pBH] = makeBHWorkflowTable(labels, pRaw)
%MAKEBHWORKFLOWTABLE Benjamini-Hochberg FDR correction with audit columns.

    labels = string(labels(:));
    pRaw = double(pRaw(:));

    nRows = numel(pRaw);
    if numel(labels) ~= nRows
        labels = string((1:nRows)');
    end

    rankVals = NaN(nRows, 1);
    mVals = NaN(nRows, 1);
    bhRaw = NaN(nRows, 1);
    pBH = NaN(nRows, 1);
    sigBH = false(nRows, 1);

    valid = isfinite(pRaw) & pRaw >= 0 & pRaw <= 1;
    m = sum(valid);
    mVals(:) = m;

    if m > 0
        validIdx = find(valid);
        [pSorted, order] = sort(pRaw(validIdx), 'ascend');
        ranks = (1:m)';
        bhSortedRaw = min((pSorted .* m) ./ ranks, 1);
        bhSortedAdj = bhSortedRaw;
        for k = m - 1:-1:1
            bhSortedAdj(k) = min(bhSortedAdj(k), bhSortedAdj(k + 1));
        end
        bhSortedAdj = min(bhSortedAdj, 1);

        targetIdx = validIdx(order);
        rankVals(targetIdx) = ranks;
        bhRaw(targetIdx) = bhSortedRaw;
        pBH(targetIdx) = bhSortedAdj;
        sigBH(targetIdx) = pBH(targetIdx) < 0.05;
    end

    bhTbl = table(labels, pRaw, rankVals, mVals, bhRaw, pBH, sigBH, ...
        'VariableNames', {'VariableOrTest', 'RawP', 'Rank', 'm', 'BH_Raw', 'BH_Adjusted', 'Significant_BH'});

    sortRank = rankVals;
    sortRank(isnan(sortRank)) = inf;
    [~, sortIdx] = sort(sortRank, 'ascend');
    bhTbl = bhTbl(sortIdx, :);
end
