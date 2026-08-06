function timeBin = makeTimeBins(hourVec, binNames)
%MAKETIMEBINS Assign observations to Morning/Afternoon/Evening/Night bins.
%
%   Morning:   06:00 to <12:00
%   Afternoon: 12:00 to <18:00
%   Evening:   18:00 to <24:00
%   Night:     00:00 to <06:00

    if nargin < 2 || isempty(binNames)
        [binNames, ~] = getTimeBinPalette();
    end

    hourVec = hourVec(:);
    n = numel(hourVec);
    labels = strings(n, 1);
    labels(:) = missing;

    valid = isfinite(hourVec);
    labels(valid) = "Night";
    labels(valid & hourVec >= 6  & hourVec < 12) = "Morning";
    labels(valid & hourVec >= 12 & hourVec < 18) = "Afternoon";
    labels(valid & hourVec >= 18 & hourVec < 24) = "Evening";

    timeBin = categorical(labels, binNames, 'Ordinal', true);
end
