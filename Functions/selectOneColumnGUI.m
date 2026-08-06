function choice = selectOneColumnGUI(headers, winTitle, promptText, allowNone)
%SELECTONECOLUMNGUI Prompt the user to select one spreadsheet column.

    if nargin < 4
        allowNone = false;
    end

    headers = cellItems(headers);

    if allowNone
        items = cellItems('<none>', headers);
        defaultItem = items{1};
    else
        items = headers;
        defaultItem = headers{1};
    end

    choice = "";

    f = uifigure('Name', char(string(winTitle)), 'Color', 'w', ...
        'Position', [300 180 520 420], 'Resize', 'on', ...
        'CloseRequestFcn', @(~, ~) doCancel());

    gl = uigridlayout(f, [4 1]);
    gl.RowHeight = {36, '1x', 40, 44};
    gl.Padding = [12 12 12 12];

    uilabel(gl, 'Text', char(string(promptText)), 'FontWeight', 'bold', 'BackgroundColor', 'w');
    lb = uilistbox(gl, 'Items', items, 'Multiselect', 'off', ...
        'Value', defaultItem, 'BackgroundColor', 'w');
    status = uilabel(gl, 'Text', '', 'BackgroundColor', 'w');
    uibutton(gl, 'Text', 'OK', 'ButtonPushedFcn', @(~, ~) doOK());

    uiwait(f);

    if isvalid(f)
        delete(f);
    end

    function doCancel()
        choice = "";
        if isvalid(f)
            uiresume(f);
        end
    end

    function doOK()
        val = lb.Value;
        if isempty(val)
            status.Text = 'Please select one column.';
            status.FontColor = [0.8 0 0];
            return;
        end
        if iscell(val)
            val = val{1};
        end
        choice = string(val);
        if isvalid(f)
            uiresume(f);
        end
    end
end
