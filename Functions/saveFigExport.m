function outPaths = saveFigExport(fig, outPath, varargin)
%SAVEFIGEXPORT Export a figure as PNG, JPEG, and/or PDF at a chosen DPI.
%
%   saveFigExport(fig, outPath)
%   saveFigExport(fig, outPath, 'Format', 'png', 'Resolution', 150)
%   saveFigExport(fig, outPath, 'Format', 'both', 'Resolution', 600)
%
%   Format: 'png', 'jpeg', 'pdf', or 'both' (pdf + jpeg)
%   Resolution: DPI (default 150 png, 900 jpeg, 600 pdf/both)
%
%   Uses exportgraphics with an explicit landscape PaperSize matching the
%   figure size. Avoids PaperPositionMode=auto, which often yields ~96 DPI
%   screen exports and portrait letter PDFs.

    p = inputParser;
    addParameter(p, 'Format', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Resolution', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
    addParameter(p, 'AlsoJpeg', false, @(x) islogical(x) || isnumeric(x));
    parse(p, varargin{:});

    fmt = lower(strtrim(char(string(p.Results.Format))));
    dpi = p.Results.Resolution;
    alsoJpeg = logical(p.Results.AlsoJpeg);

    [outDir, stem, ext] = fileparts(outPath);
    if ~isempty(outDir)
        ensureDir(outDir);
    end

    if isempty(fmt)
        if strcmpi(ext, '.pdf')
            fmt = 'pdf';
        elseif strcmpi(ext, '.png')
            fmt = 'png';
        elseif strcmpi(ext, '.jpg') || strcmpi(ext, '.jpeg')
            fmt = 'jpeg';
        else
            fmt = 'png';
        end
    end

    if strcmp(fmt, 'both')
        alsoJpeg = true;
        fmt = 'pdf';
    end

    if isempty(dpi) || ~isfinite(dpi) || dpi <= 0
        switch fmt
            case 'pdf'
                dpi = 600;
            case 'jpeg'
                dpi = 900;
            otherwise
                dpi = 150;
        end
    end

    prepareLandscapePaper(fig);

    axs = findall(fig, 'Type', 'axes');
    for ii = 1:numel(axs)
        try
            axs(ii).Toolbar.Visible = 'off';
        catch
        end
    end

    outPaths = {};
    dpi = round(dpi);

    if strcmp(fmt, 'pdf')
        pdfPath = fullfile(outDir, [stem '.pdf']);
        writePdf(fig, pdfPath, dpi);
        outPaths{end + 1} = pdfPath; %#ok<AGROW>
        if alsoJpeg
            jpgPath = fullfile(outDir, [stem '.jpg']);
            writeJpeg(fig, jpgPath, dpi);
            outPaths{end + 1} = jpgPath; %#ok<AGROW>
        end
    elseif strcmp(fmt, 'png')
        pngPath = fullfile(outDir, [stem '.png']);
        writePng(fig, pngPath, dpi);
        outPaths{end + 1} = pngPath;
    else
        jpgPath = fullfile(outDir, [stem '.jpg']);
        writeJpeg(fig, jpgPath, dpi);
        outPaths{end + 1} = jpgPath;
    end
end

function prepareLandscapePaper(fig)
% Lock paper to the figure's landscape size (width >= height).

    set(fig, 'InvertHardcopy', 'off', 'Color', 'w');

    oldUnits = fig.Units;
    fig.Units = 'centimeters';
    pos = fig.Position;
    figW = pos(3);
    figH = pos(4);
    if ~isfinite(figW) || figW <= 0
        figW = 18;
    end
    if ~isfinite(figH) || figH <= 0
        figH = 8.5;
    end

    if figW < figH
        tmp = figW;
        figW = figH;
        figH = tmp;
        fig.Position = [pos(1) pos(2) figW figH];
    end

    set(fig, ...
        'PaperUnits', 'centimeters', ...
        'PaperOrientation', 'landscape', ...
        'PaperSize', [figW figH], ...
        'PaperPosition', [0 0 figW figH], ...
        'PaperPositionMode', 'manual');

    try
        fig.Units = oldUnits;
    catch
    end
end

function writePng(fig, outPath, dpi)
    try
        exportgraphics(fig, outPath, 'Resolution', dpi);
    catch
        print(fig, outPath, '-dpng', sprintf('-r%d', dpi));
    end
end

function writeJpeg(fig, outPath, dpi)
    try
        exportgraphics(fig, outPath, 'Resolution', dpi);
    catch
        print(fig, outPath, '-djpeg', sprintf('-r%d', dpi));
    end
end

function writePdf(fig, outPath, dpi)
% Vector landscape PDF cropped to the figure (matches submitted Fig. 3 export).
    try
        set(fig, 'Renderer', 'painters');
    catch
    end
    try
        exportgraphics(fig, outPath, ...
            'ContentType', 'vector', ...
            'BackgroundColor', 'w', ...
            'Resolution', dpi);
    catch
        try
            print(fig, outPath, '-dpdf', '-painters', sprintf('-r%d', dpi));
        catch
            print(fig, outPath, '-dpdf', sprintf('-r%d', dpi));
        end
    end
end
