function s = safeSheetName(s)
%SAFESHEETNAME Truncate and sanitise an Excel sheet name.
    s = char(string(s));
    s = regexprep(s, '[\\/\?\*\[\]:]', '_');
    if strlength(string(s)) > 31
        s = s(1:31);
    end
    if isempty(s)
        s = 'Sheet1';
    end
end
