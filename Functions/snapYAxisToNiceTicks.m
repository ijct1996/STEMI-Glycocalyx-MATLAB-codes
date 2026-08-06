function snapYAxisToNiceTicks(ax, rawBottom, rawTop)
%SNAPYAXISTONICETICKS Snap y-limits to labelled ticks (axis ends on top tick).

    if nargin < 3 || isempty(ax) || ~isgraphics(ax, 'axes')
        return
    end

    if ~isfinite(rawBottom) || ~isfinite(rawTop)
        return
    end

    if rawTop <= rawBottom
        rawTop = rawBottom + 1;
    end

    if rawBottom >= 0
        yBottom = 0;
    else
        tmpRange = rawTop - rawBottom;
        tmpStep = niceTickStep(tmpRange, 10);
        yBottom = floor(rawBottom / tmpStep) * tmpStep;
    end

    targetRange = rawTop - yBottom;
    tickStep = niceTickStep(targetRange, 10);

    if ~isfinite(tickStep) || tickStep <= 0
        return
    end

    if rawBottom < 0
        yBottom = floor(rawBottom / tickStep) * tickStep;
    end

    yTop = ceil(rawTop / tickStep) * tickStep;

    if abs(yTop - rawTop) < 1e-10
        yTop = yTop + tickStep;
    end

    if yTop <= yBottom
        yTop = yBottom + tickStep;
    end

    newTicks = yBottom:tickStep:yTop;
    newTicks = round(newTicks, 10);
    newTicks(abs(newTicks) < 1e-10) = 0;

    try
        set(ax, 'YTickMode', 'auto');
        set(ax, 'YTickLabelMode', 'auto');
    catch
    end

    ylim(ax, [yBottom, yTop]);
    set(ax, 'YTick', newTicks);
    set(ax, 'YTickLabel', formatYTickLabels(newTicks, tickStep));
    set(ax, 'YTickMode', 'manual');
    set(ax, 'YTickLabelMode', 'manual');

    try
        ax.YAxis.Exponent = 0;
    catch
    end
end
