function labels = formatYTickLabels(ticks, tickStep)
%FORMATYTICKLABELS Build explicit y-axis tick labels without trailing clutter.

    ticks = ticks(:);

    if nargin < 2 || isempty(tickStep)
        tickStep = 1;
    end

    if tickStep >= 1 || all(abs(ticks - round(ticks)) < 1e-10)
        labels = cellstr(compose('%.0f', ticks));
    elseif tickStep >= 0.1
        labels = cellstr(compose('%.1f', ticks));
    elseif tickStep >= 0.01
        labels = cellstr(compose('%.2f', ticks));
    elseif tickStep >= 0.001
        labels = cellstr(compose('%.3f', ticks));
    else
        labels = cellstr(compose('%.3g', ticks));
    end

    labels = regexprep(labels, '(\.\d*?)0+$', '$1');
    labels = regexprep(labels, '\.$', '');
    labels = regexprep(labels, '^-0$', '0');
end
