function addSigBrackets(ax, pairs, pvals, yStart)
%ADDSIGBRACKETS Draw significance brackets above grouped box plots.

    if isempty(pairs)
        return;
    end

    span = abs(pairs(:, 2) - pairs(:, 1));
    [~, ord] = sortrows([span(:), pvals(:)], [1, 2]);
    pairs = pairs(ord, :);
    pvals = pvals(ord);

    yl = ylim(ax);
    yRange = yl(2) - yl(1);
    if yRange <= 0
        yRange = 1;
    end

    baseY = max(yStart, yl(2)) + 0.04 * yRange;
    stepY = 0.07 * yRange;
    usedLevels = zeros(0, 3);

    for i = 1:size(pairs, 1)
        x1 = min(pairs(i, 1), pairs(i, 2));
        x2 = max(pairs(i, 1), pairs(i, 2));

        level = 0;
        while true
            conflict = false;
            for j = 1:size(usedLevels, 1)
                ux1 = usedLevels(j, 1);
                ux2 = usedLevels(j, 2);
                ul = usedLevels(j, 3);
                if ul == level && ~(x2 < ux1 || x1 > ux2)
                    conflict = true;
                    break;
                end
            end
            if ~conflict
                break;
            end
            level = level + 1;
        end
        usedLevels(end + 1, :) = [x1, x2, level]; %#ok<AGROW>

        y = baseY + level * stepY;
        plot(ax, [x1, x1, x2, x2], [y, y + 0.015 * yRange, y + 0.015 * yRange, y], ...
            'k-', 'LineWidth', 1.2);
        text(ax, mean([x1, x2]), y + 0.02 * yRange, pToStars(pvals(i)), ...
            'HorizontalAlignment', 'center', ...
            'FontWeight', 'bold', ...
            'FontName', 'Arial', ...
            'FontSize', 18);
    end

    ylim(ax, [yl(1), baseY + (max(usedLevels(:, 3)) + 1) * stepY + 0.10 * yRange]);
end
