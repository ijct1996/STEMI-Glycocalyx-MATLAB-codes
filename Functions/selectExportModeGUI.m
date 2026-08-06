function mode = selectExportModeGUI(varargin)
%SELECTEXPORTMODEGUI Choose Dev vs Publication figure export settings.
%
%   mode = selectExportModeGUI()
%   mode = selectExportModeGUI('Title', 'STEMI PCA: export mode')
%
%   mode.Name        - 'dev' or 'publication'
%   mode.Format      - 'png' or 'jpeg'
%   mode.Resolution  - DPI (150 Dev, 600 Publication)
%   mode.Extension   - '.png' or '.jpg'
%   mode.AlsoJpeg    - unused (kept for compatibility; always false)
%   mode.Label       - short display string

    p = inputParser;
    addParameter(p, 'Title', 'Export mode', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Default', 'dev', @(x) ischar(x) || isstring(x));
    parse(p, varargin{:});
    winTitle = char(string(p.Results.Title));
    defaultMode = lower(strtrim(char(string(p.Results.Default))));

    items = { ...
        'Dev mode — medium-quality PNG (150 DPI)', ...
        'Publication mode — 600 DPI JPEG'};
    tags = {'dev', 'publication'};

    if strcmp(defaultMode, 'publication')
        defaultItem = items{2};
    else
        defaultItem = items{1};
    end

    choice = "";

    f = uifigure('Name', winTitle, 'Color', 'w', ...
        'Position', [340 240 560 360], 'Resize', 'on', ...
        'CloseRequestFcn', @(~, ~) doCancel());

    gl = uigridlayout(f, [4 1]);
    gl.RowHeight = {40, '1x', 56, 44};
    gl.Padding = [14 14 14 14];
    gl.RowSpacing = 10;

    uilabel(gl, 'Text', 'Select figure export mode:', ...
        'FontWeight', 'bold', 'BackgroundColor', 'w');

    lb = uilistbox(gl, 'Items', items, 'Multiselect', 'off', ...
        'Value', defaultItem, 'BackgroundColor', 'w');

    status = uilabel(gl, 'Text', [ ...
        'Dev: medium-quality PNG for quick on-screen checks. ' ...
        'Publication: 600 DPI JPEG for manuscript use.'], ...
        'WordWrap', 'on', 'BackgroundColor', 'w');

    uibutton(gl, 'Text', 'OK', 'ButtonPushedFcn', @(~, ~) doOK());

    uiwait(f);

    if isvalid(f)
        delete(f);
    end

    if strlength(choice) == 0
        error('selectExportModeGUI:Cancelled', 'Export mode selection cancelled.');
    end

    mode = exportModeFromName(choice);

    function doCancel()
        choice = "";
        if isvalid(f)
            uiresume(f);
        end
    end

    function doOK()
        val = lb.Value;
        if isempty(val)
            status.Text = 'Please select Dev or Publication mode.';
            status.FontColor = [0.8 0 0];
            return
        end
        if iscell(val)
            val = val{1};
        end
        idx = find(strcmp(items, char(string(val))), 1);
        if isempty(idx)
            status.Text = 'Please select Dev or Publication mode.';
            status.FontColor = [0.8 0 0];
            return
        end
        choice = string(tags{idx});
        if isvalid(f)
            uiresume(f);
        end
    end
end

function mode = exportModeFromName(name)
    name = lower(strtrim(char(string(name))));
    mode = struct();
    if strcmp(name, 'publication')
        mode.Name = 'publication';
        mode.Format = 'jpeg';
        mode.Resolution = 600;
        mode.Extension = '.jpg';
        mode.AlsoJpeg = false;
        mode.Label = 'Publication (600 DPI JPEG)';
    else
        mode.Name = 'dev';
        mode.Format = 'png';
        mode.Resolution = 150;
        mode.Extension = '.png';
        mode.AlsoJpeg = false;
        mode.Label = 'Dev (medium-quality PNG, 150 DPI)';
    end
end
