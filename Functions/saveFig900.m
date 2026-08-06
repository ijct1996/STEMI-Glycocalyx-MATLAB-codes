function saveFig900(fig, outPath)
%SAVEFIG900 Export a figure as 900 DPI JPEG (dev / high-res raster).
%
%   Uses exportgraphics with locked landscape PaperSize. Does not set
%   PaperPositionMode=auto (that commonly produces ~96 DPI screen dumps).

    [outDir, stem, ext] = fileparts(outPath);
    if isempty(ext) || (~strcmpi(ext, '.jpg') && ~strcmpi(ext, '.jpeg'))
        outPath = fullfile(outDir, [stem '.jpg']);
    end
    if ~isempty(outDir)
        ensureDir(outDir);
    end

    saveFigExport(fig, outPath, 'Format', 'jpeg', 'Resolution', 900);
end
