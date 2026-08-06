function x = toNumericFlexible(v, varName)
%TONUMERICFLEXIBLE Coerce spreadsheet values to double; non-numeric -> NaN.
%
%   Missing or unparseable values become NaN and are excluded downstream
%   by isfinite() / complete-case filters in each analysis script.

    if nargin < 2
        varName = 'variable';
    end

    if istable(v)
        v = v{:, :};
    end

    if isnumeric(v)
        x = double(v(:));
        return;
    end
    if islogical(v)
        x = double(v(:));
        return;
    end
    if iscategorical(v)
        v = string(v);
    end
    if isdatetime(v) || isduration(v)
        x = datenum(v);
        x = double(x(:));
        return;
    end

    s = string(v(:));
    s = strtrim(s);
    s = replace(s, ',', '.');

    missingTokens = ["", "na", "n/a", "nan", "null", "-", ".", "nd", "missing", "n.a.", "na."];
    s(ismissing(s) | ismember(lower(s), missingTokens)) = missing;

    x = nan(numel(s), 1);
    for i = 1:numel(s)
        if ismissing(s(i))
            continue;
        end
        val = str2double(s(i));
        if isfinite(val)
            x(i) = val;
        else
            % Strip trailing text/units, e.g. "12.4 ng/mL"
            cleaned = regexprep(s(i), '[^0-9\.\-]', '');
            val = str2double(cleaned);
            if isfinite(val)
                x(i) = val;
            end
        end
    end

    if all(isnan(x)) && any(~ismissing(s))
        warning('toNumericFlexible:ParseWarning', ...
            'Could not parse numeric values for column "%s".', varName);
    end
end
