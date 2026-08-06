function info = parseColumnLabel(header)
%PARSECOLUMNLABEL Parse "Variable name (units)" from a spreadsheet header.
%
%   info.name         - variable name without units
%   info.units        - unit string (empty if absent)
%   info.displayLabel - full trimmed header
%   info.yLabel       - name with units for axis labels
%   info.fileStem     - filesystem-safe stem for output files

    s = strtrim(string(header));
    tok = regexp(s, '^(.*?)\((.+)\)\s*$', 'tokens', 'once');

    if ~isempty(tok)
        info.name = strtrim(string(tok{1}));
        info.units = strtrim(string(tok{2}));
    else
        info.name = s;
        info.units = "";
    end

    info.displayLabel = s;

    if strlength(info.units) > 0
        info.yLabel = info.name + " (" + info.units + ")";
    else
        info.yLabel = info.name;
    end

    info.fileStem = matlab.lang.makeValidName(char(info.name));
    if isempty(info.fileStem)
        info.fileStem = matlab.lang.makeValidName(char(s));
    end
end
