function choices = selectMultipleColumnsGUI(headers, excludeCols, winTitle, promptText)
%SELECTMULTIPLECOLUMNSGUI Prompt the user to select multiple spreadsheet columns.

    headers = cellItems(headers);
    excludeCols = cellItems(excludeCols);
    excludeCols = excludeCols(~strcmp(excludeCols, '<none>') & ~strcmp(excludeCols, ''));
    headers = headers(~ismember(headers, excludeCols));

    if isempty(headers)
        error('selectMultipleColumnsGUI:NoColumns', 'No columns available to select.');
    end

    choices = strings(0, 1);

    f = uifigure('Name', char(string(winTitle)), 'Color', 'w', ...
        'Position', [260 120 620 560], 'Resize', 'on', ...
        'CloseRequestFcn', @(~, ~) doCancel());

    gl = uigridlayout(f, [5 3]);
    gl.RowHeight = {36, '1x', 38, 44, 24};
    gl.ColumnWidth = {'1x', 110, 110};
    gl.Padding = [12 12 12 12];

    lbl = uilabel(gl, 'Text', char(string(promptText)), 'FontWeight', 'bold', 'BackgroundColor', 'w');
    lbl.Layout.Row = 1;
    lbl.Layout.Column = [1 3];

    lb = uilistbox(gl, 'Items', headers, 'Multiselect', 'on', 'BackgroundColor', 'w');
    lb.Layout.Row = 2;
    lb.Layout.Column = [1 3];

    btnAll = uibutton(gl, 'Text', 'Select all', 'ButtonPushedFcn', @(~, ~) doAll());
    btnAll.Layout.Row = 3;
    btnAll.Layout.Column = 2;

    btnClr = uibutton(gl, 'Text', 'Clear', 'ButtonPushedFcn', @(~, ~) doClear());
    btnClr.Layout.Row = 3;
    btnClr.Layout.Column = 3;

    btnOK = uibutton(gl, 'Text', 'OK', 'ButtonPushedFcn', @(~, ~) doOK());
    btnOK.Layout.Row = 4;
    btnOK.Layout.Column = 3;

    status = uilabel(gl, 'Text', 'Select one or more columns.', 'BackgroundColor', 'w');
    status.Layout.Row = 5;
    status.Layout.Column = [1 3];

    uiwait(f);

    if isvalid(f)
        delete(f);
    end

    choices = string(choices);

    function doCancel()
        choices = strings(0, 1);
        if isvalid(f)
            uiresume(f);
        end
    end

    function doAll()
        lb.Value = lb.Items;
        nSel = numel(lb.Value);
        if ischar(lb.Value)
            nSel = 1;
        end
        status.Text = sprintf('%d columns selected.', nSel);
        status.FontColor = [0 0 0];
    end

    function doClear()
        lb.Value = {};
        status.Text = 'Selection cleared.';
        status.FontColor = [0 0 0];
    end

    function doOK()
        val = lb.Value;
        if isempty(val)
            status.Text = 'Please select at least one column.';
            status.FontColor = [0.8 0 0];
            return;
        end
        if ischar(val)
            choices = string({val});
        elseif iscell(val)
            choices = string(val(:));
        else
            choices = string(val);
        end
        choices = choices(choices ~= "");
        if isempty(choices)
            status.Text = 'Please select at least one column.';
            status.FontColor = [0.8 0 0];
            return;
        end
        if isvalid(f)
            uiresume(f);
        end
    end
end
