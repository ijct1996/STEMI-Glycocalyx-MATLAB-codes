function setDynamicYAxisFromData(ax, varargin)
%SETDYNAMICYAXISFROMDATA Data-driven y limits snapped to labelled ticks.
%
%   setDynamicYAxisFromData(ax, y1, y2, ...)
%
%   Accepts one or more numeric vectors (e.g. raw data, fitted curves).
%   Non-finite values are ignored. Non-negative data use a zero baseline;
%   the upper limit is padded then snapped so the axis ends on a tick label.

    allY = [];
    for ii = 1:nargin - 1
        yi = varargin{ii};
        if isempty(yi)
            continue
        end
        yi = yi(:);
        allY = [allY; yi(isfinite(yi))]; %#ok<AGROW>
    end

    if isempty(allY)
        snapYAxisToNiceTicks(ax, 0, 1);
        return
    end

    yMin = min(allY);
    yMax = max(allY);

    if yMax == yMin
        pad = max(abs(yMax) * 0.10, 1);
        snapYAxisToNiceTicks(ax, yMin - pad, yMax + pad);
        return
    end

    yRange = yMax - yMin;

    if yMin >= 0
        rawBottom = 0;
        rawTop = yMax + 0.08 * max(yMax, yRange);
    else
        pad = 0.08 * yRange;
        rawBottom = yMin - pad;
        rawTop = yMax + pad;
    end

    snapYAxisToNiceTicks(ax, rawBottom, rawTop);
end
