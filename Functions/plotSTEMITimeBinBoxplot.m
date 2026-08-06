function outPath = plotSTEMITimeBinBoxplot(y, timeBin, binNames, binCols, yLabel, outPath, sigPairs, sigP, fileStem)
%PLOTSTEMITIMEBINBOXPLOT Create and save a publication-style STEMI time-bin box plot.

    if nargin < 9
        fileStem = '';
    end

    fig = figure('Color', 'w', 'Visible', 'off', 'Units', 'inches', ...
        'Position', [1 1 7.6 5.2], 'PaperUnits', 'inches', ...
        'PaperPosition', [0 0 7.6 5.2], 'PaperPositionMode', 'manual');
    ax = axes(fig);
    hold(ax, 'on');

    xBase = 1:numel(binNames);
    for bb = 1:numel(binNames)
        bn = categorical(binNames(bb), binNames, 'Ordinal', true);
        yb = y(timeBin == bn);
        yb = yb(isfinite(yb));
        if isempty(yb)
            continue;
        end

        try
            bc = boxchart(repmat(xBase(bb), numel(yb), 1), yb);
            bc.BoxFaceColor = binCols(bb, :);
            bc.MarkerStyle = 'none';
            bc.LineWidth = 1.0;
            bc.HandleVisibility = 'off';
            if isprop(bc, 'BoxWidth')
                bc.BoxWidth = 0.55;
            end
        catch
        end

        xj = xBase(bb) + (rand(size(yb)) - 0.5) * 0.18;
        hs = scatter(ax, xj, yb, 18, 'filled', ...
            'MarkerFaceColor', binCols(bb, :), ...
            'MarkerFaceAlpha', 0.55, ...
            'MarkerEdgeColor', 'none');
        hs.HandleVisibility = 'off';
    end

    set(ax, 'XTick', xBase, 'XTickLabel', cellstr(binNames));
    xlim(ax, [0.5, numel(binNames) + 0.5]);
    ylabel(ax, yLabel, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel(ax, '');

    yUse = y(isfinite(y));
    setDynamicYAxisFromData(ax, yUse);

    if nargin >= 8 && ~isempty(sigPairs)
        yTop = ylim(ax);
        addSigBrackets(ax, sigPairs, sigP, yTop(2));
        finalizeDynamicYAxis(fig);
    end
    applyPublicationAxes(ax);
    set(ax, 'Position', [0.14 0.18 0.82 0.74]);

    saveFig900(fig, outPath);
    close(fig);
end
