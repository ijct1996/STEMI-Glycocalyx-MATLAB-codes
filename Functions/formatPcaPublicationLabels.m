function labelsOut = formatPcaPublicationLabels(labelsIn)
%FORMATPCAPUBLICATIONLABELS Publication labels for PCA loadings heatmap.
%
%   Matches the submitted STEMI Clock figure (PCA loadings panel):
%   units are stripped for most variables; Discharge always shows
%   "Discharge (days)"; EF is shown as "Ejection Fraction".

    if isstring(labelsIn)
        labelsIn = cellstr(labelsIn);
    elseif ischar(labelsIn)
        labelsIn = cellstr(labelsIn);
    end

    labelsOut = cell(size(labelsIn));
    for i = 1:numel(labelsIn)
        labelsOut{i} = formatOne(labelsIn{i});
    end
end

function s = formatOne(lab)
    raw = strtrim(char(string(lab)));
    if isempty(raw)
        s = raw;
        return
    end

    info = parseColumnLabel(raw);
    name = char(info.name);
    hay = lower(strtrim(sprintf('%s %s %s', raw, name, char(info.units))));

    if contains(hay, 'discharge')
        s = 'Discharge (days)';
    elseif contains(hay, 'ejection') || strcmpi(strtrim(name), 'EF') || ...
            ~isempty(regexp(hay, '(^|[^a-z])ef([^a-z]|$)', 'once'))
        s = 'Ejection Fraction';
    elseif contains(hay, 'cortical')
        s = 'Cortical Stiffness';
    elseif contains(hay, 'egc height') || contains(hay, 'glycocalyx height') || ...
            contains(hay, 'gheight')
        s = 'eGC Height';
    elseif contains(hay, 'egc stiff') || contains(hay, 'glycocalyx stiff') || ...
            contains(hay, 'gstiff')
        s = 'eGC Stiffness';
    elseif contains(hay, 'syndecan')
        s = 'Syndecan-1';
    elseif contains(hay, 'c3a')
        s = 'C3a';
    elseif contains(hay, 'c5a')
        s = 'C5a';
    else
        % Generic: variable name without units (Discharge handled above).
        s = char(info.name);
        if isempty(s)
            s = raw;
        end
    end
end
