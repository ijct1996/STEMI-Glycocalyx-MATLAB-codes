function mask = usableRowMask(y, hours, timeBin)
%USABLEROWMASK True for rows with finite outcome, clock time, and time bin.
%
%   NaN, Inf, missing time, and unassigned time bins are excluded.

    mask = isfinite(y);

    if nargin >= 2 && ~isempty(hours)
        mask = mask & isfinite(hours);
    end

    if nargin >= 3 && ~isempty(timeBin)
        mask = mask & ~isundefined(timeBin);
    end
end
