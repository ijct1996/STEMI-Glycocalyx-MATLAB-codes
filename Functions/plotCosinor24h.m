function outPath = plotCosinor24h(t, y, fitOut, yLabel, outPath)
%PLOTCOSINOR24H 24 h STEMI cosinor figure with scatter and fitted curve.

    tfine = linspace(0, 24, 721)';
    c = cos(2 * pi * tfine / 24);
    s = sin(2 * pi * tfine / 24);
    yNull = fitOut.betaNull(1) * ones(size(tfine));
    yCos = fitOut.betaCos(1) + fitOut.betaCos(2) * c + fitOut.betaCos(3) * s;

    if isfield(fitOut, 'isRhythmic') && fitOut.isRhythmic
        yCurve = yCos;
    else
        yCurve = yNull;
    end

    fig = figure('Color', 'w', 'Visible', 'off', 'Units', 'inches', ...
        'Position', [1 1 7.6 4.9], 'PaperUnits', 'inches', ...
        'PaperPosition', [0 0 7.6 4.9], 'PaperPositionMode', 'manual');
    ax = axes(fig);
    hold(ax, 'on');

    scatter(ax, t, y, 44, 'filled', ...
        'MarkerFaceColor', [0 0 0], ...
        'MarkerEdgeColor', 'none', ...
        'MarkerFaceAlpha', 0.70);
    plot(ax, tfine, yCurve, '-', 'Color', [0.80 0.00 0.00], 'LineWidth', 3.0);

    xlabel(ax, 'Clock time (h)', 'FontWeight', 'bold', 'Interpreter', 'none');
    ylabel(ax, yLabel, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlim(ax, [0 24]);
    xticks(ax, 0:3:24);
    setDynamicYAxisFromData(ax, y, yCurve);
    applyPublicationAxes(ax);
    set(ax, 'Position', [0.17 0.24 0.79 0.69]);

    saveFig900(fig, outPath);
    close(fig);
end
