function outPaths = plotPcaPublication(score, explained, loadings, timeBin, binNames, binCols, labels, outPath, varargin)
%PLOTPCAPUBLICATION Combined PC1/PC2 score plot and loadings heatmap.
%
%   Layout matches STEMI_Clock_IJT_Figure3.pdf:
%     A  PC1/PC2 scores by time bin (colour legend below panels)
%     B  PC1/PC2 loadings heatmap (parula, "Loading" colorbar)
%   Discharge always labelled "Discharge (days)".
%   Panel letters are omitted (added later in figure assembly if needed).
%
%   Optional Name-Value:
%     'ExportMode'  - struct from selectExportModeGUI (Format/Resolution)
%     'Format'      - 'png', 'jpeg', 'pdf', or 'both'
%     'Resolution'  - DPI
%
%   outPaths - cellstr of written figure files.

    p = inputParser;
    addParameter(p, 'ExportMode', [], @(x) isempty(x) || isstruct(x));
    addParameter(p, 'Format', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Resolution', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
    parse(p, varargin{:});

    fmt = char(string(p.Results.Format));
    dpi = p.Results.Resolution;
    alsoJpeg = false;
    if ~isempty(p.Results.ExportMode)
        em = p.Results.ExportMode;
        if isfield(em, 'Format') && isempty(fmt)
            fmt = char(string(em.Format));
        end
        if isfield(em, 'Resolution') && isempty(dpi)
            dpi = em.Resolution;
        end
        if isfield(em, 'AlsoJpeg')
            alsoJpeg = logical(em.AlsoJpeg);
        end
        if isfield(em, 'Extension') && ~isempty(em.Extension)
            [outDir, stem] = fileparts(outPath);
            outPath = fullfile(outDir, [stem char(string(em.Extension))]);
        end
    end

    nPC = size(score, 2);
    nHeat = min(2, size(loadings, 2));
    pubLabels = formatPcaPublicationLabels(labels);

    if nPC >= 2
        scoreY = score(:, 2);
        pc2Label = sprintf('PC2 (%.1f%%)', explained(min(2, numel(explained))));
    else
        scoreY = zeros(size(score, 1), 1);
        pc2Label = 'PC2';
    end

    % Same physical size / landscape crop as submitted Figure 3 (18 x 8.5 cm).
    fig = figure('Color', 'w', 'Visible', 'off', 'Units', 'centimeters', ...
        'Position', [2 2 18 8.5], 'PaperUnits', 'centimeters', ...
        'PaperOrientation', 'landscape', ...
        'PaperSize', [18 8.5], ...
        'PaperPosition', [0 0 18 8.5], ...
        'PaperPositionMode', 'manual', ...
        'Renderer', 'painters');
    tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    ax1 = nexttile(tl, 1);
    hold(ax1, 'on');
    for bb = 1:numel(binNames)
        bn = categorical(binNames(bb), binNames, 'Ordinal', true);
        idxB = (timeBin == bn);
        if any(idxB)
            scatter(ax1, score(idxB, 1), scoreY(idxB), 30, 'filled', ...
                'MarkerFaceColor', binCols(bb, :), ...
                'MarkerFaceAlpha', 0.60, ...
                'MarkerEdgeColor', 'none', ...
                'HandleVisibility', 'off');
        end
    end
    xlabel(ax1, sprintf('PC1 (%.1f%%)', explained(1)), 'FontWeight', 'bold');
    ylabel(ax1, pc2Label, 'FontWeight', 'bold');
    applyPcaPublicationAxes(ax1);

    hLeg = gobjects(numel(binNames), 1);
    for i = 1:numel(binNames)
        hLeg(i) = plot(ax1, nan, nan, '-', ...
            'LineWidth', 6, 'Color', binCols(i, :));
    end
    % Colour key under the figure (does not compress the scatter axes).
    leg = legend(ax1, hLeg, cellstr(binNames), ...
        'Orientation', 'horizontal', 'NumColumns', 4);
    set(leg, ...
        'Box', 'off', ...
        'FontName', 'Arial', ...
        'FontSize', 8, ...
        'Color', 'none', ...
        'EdgeColor', 'none');
    try
        leg.ItemTokenSize = [14, 6];
    catch
    end
    try
        leg.Layout.Tile = 'south';
    catch
        set(leg, 'Location', 'southoutside');
    end
    leg.AutoUpdate = 'off';

    ax2 = nexttile(tl, 2);
    heat = loadings(:, 1:nHeat);
    maxAbs = max(abs(heat), [], 'all');
    if ~isfinite(maxAbs) || maxAbs == 0
        maxAbs = 1;
    end
    imagesc(ax2, heat);
    set(ax2, 'YDir', 'reverse');
    colormap(ax2, parula);
    clim(ax2, [-maxAbs, maxAbs]);
    cb = colorbar(ax2);
    ylabel(cb, 'Loading', 'FontWeight', 'bold', 'FontName', 'Arial', 'FontSize', 10);
    set(ax2, 'XTick', 1:nHeat, 'XTickLabel', compose('PC%d', 1:nHeat), ...
        'YTick', 1:numel(pubLabels), 'YTickLabel', pubLabels, ...
        'TickLabelInterpreter', 'none');
    xlabel(ax2, 'Principal component', 'FontWeight', 'bold');
    ylabel(ax2, 'Variable', 'FontWeight', 'bold');
    applyPcaPublicationAxes(ax2);
    try
        cb.FontName = 'Arial';
        cb.FontSize = 9;
    catch
    end

    args = {};
    if ~isempty(fmt)
        args = [args, {'Format', fmt}]; %#ok<AGROW>
    elseif isempty(dpi)
        fmt = 'png';
        dpi = 150;
        args = [args, {'Format', fmt}]; %#ok<AGROW>
    end
    if ~isempty(dpi)
        args = [args, {'Resolution', dpi}]; %#ok<AGROW>
    end
    if alsoJpeg
        args = [args, {'AlsoJpeg', true}]; %#ok<AGROW>
    end
    outPaths = saveFigExport(fig, outPath, args{:});
    if isempty(outPaths)
        outPaths = {outPath};
    end
    close(fig);
end

function applyPcaPublicationAxes(ax)
% Compact Arial styling used for STEMI_Clock_IJT_Figure3.pdf.
    set(ax, ...
        'TickDir', 'out', ...
        'Box', 'off', ...
        'FontName', 'Arial', ...
        'FontSize', 9, ...
        'FontWeight', 'normal', ...
        'XGrid', 'off', ...
        'YGrid', 'off', ...
        'XAxisLocation', 'bottom', ...
        'YAxisLocation', 'left', ...
        'LineWidth', 1.0, ...
        'TickLabelInterpreter', 'none', ...
        'Layer', 'top');

    try
        ax.XLabel.FontName = 'Arial';
        ax.XLabel.FontSize = 11;
        ax.XLabel.FontWeight = 'bold';
        ax.YLabel.FontName = 'Arial';
        ax.YLabel.FontSize = 11;
        ax.YLabel.FontWeight = 'bold';
    catch
    end
end
