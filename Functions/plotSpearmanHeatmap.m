function outPath = plotSpearmanHeatmap(R, Pbh, labels, outPath)
%PLOTSPEARMANHEATMAP Publication-style Spearman correlation heatmap (900 DPI JPEG).

    labels = cellstr(string(labels));
    nVars = numel(labels);

    figW = max(8.5, 0.95 * nVars + 4.5);
    figH = max(7.5, 0.85 * nVars + 3.5);
    fig = figure('Color', 'w', 'Visible', 'off', 'Units', 'inches', ...
        'Position', [1 1 figW figH], 'PaperUnits', 'inches', ...
        'PaperPosition', [0 0 figW figH], 'PaperPositionMode', 'manual');

    if nVars <= 10
        tickFont = 14;
        cellFont = 11;
    else
        tickFont = 12;
        cellFont = 9;
    end

    ax = axes(fig, 'Position', [0.22 0.30 0.58 0.58]);
    imagesc(ax, R, 'AlphaData', ~isnan(R));
    axis(ax, 'square');
    set(ax, 'CLim', [-1 1], 'Color', [1 1 1]);
    colormap(ax, blueWhiteRedMap(256));

    cb = colorbar(ax);
    cb.Label.String = 'Spearman rho';
    cb.FontName = 'Arial';
    cb.FontSize = tickFont;
    cb.Label.FontName = 'Arial';
    cb.Label.FontSize = tickFont + 2;
    cb.Label.FontWeight = 'bold';

    set(ax, 'XTick', 1:nVars, 'XTickLabel', labels, ...
        'YTick', 1:nVars, 'YTickLabel', labels, ...
        'FontName', 'Arial', 'FontSize', tickFont);
    xtickangle(ax, 45);
    title(ax, '');
    applyPublicationAxes(ax);

    for i = 1:nVars
        for j = 1:nVars
            if isnan(R(i, j))
                continue;
            end
            if i == j
                txt = '1.00';
            else
                txt = sprintf('%.2f', R(i, j));
                if isfinite(Pbh(i, j)) && Pbh(i, j) < 0.05
                    txt = [txt, '*']; %#ok<AGROW>
                end
            end
            if abs(R(i, j)) > 0.55
                tcol = [1 1 1];
            else
                tcol = [0 0 0];
            end
            text(ax, j, i, txt, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'FontSize', cellFont, ...
                'FontName', 'Arial', 'Color', tcol, 'Interpreter', 'none');
        end
    end

    saveFig900(fig, outPath);
    close(fig);
end
