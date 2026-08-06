function step = niceTickStep(rangeVal, targetTicks)
%NICETICKSTEP Return a publication-friendly tick step for the supplied range.

    if nargin < 2 || isempty(targetTicks)
        targetTicks = 10;
    end

    if ~isfinite(rangeVal) || rangeVal <= 0
        step = 1;
        return
    end

    rawStep = rangeVal / max(targetTicks, 2);
    exponentVal = floor(log10(rawStep));
    scaled = rawStep / (10 ^ exponentVal);

    niceBases = [1 2 2.5 5 10];
    idx = find(scaled <= niceBases, 1, 'first');
    if isempty(idx)
        base = 10;
    else
        base = niceBases(idx);
    end

    step = base * (10 ^ exponentVal);
end
