function [R, P, N] = pairwiseSpearman(M, minN)
%PAIRWISESPEARMAN Pairwise Spearman correlations with sample-size tracking.

    if nargin < 2 || isempty(minN)
        minN = 6;
    end

    nVars = size(M, 2);
    R = nan(nVars);
    P = nan(nVars);
    N = zeros(nVars);

    for i = 1:nVars
        for j = 1:nVars
            if i == j
                R(i, j) = 1;
                P(i, j) = 0;
                N(i, j) = sum(isfinite(M(:, i)));
                continue;
            end

            xi = M(:, i);
            xj = M(:, j);
            ok = isfinite(xi) & isfinite(xj);
            nPair = sum(ok);

            N(i, j) = nPair;
            if nPair < minN
                continue;
            end

            xi2 = xi(ok);
            xj2 = xj(ok);
            if numel(unique(xi2)) < 2 || numel(unique(xj2)) < 2
                continue;
            end

            [rho, pv] = corr(xi2, xj2, 'Type', 'Spearman', 'Rows', 'complete');
            R(i, j) = rho;
            P(i, j) = pv;
        end
    end
end
