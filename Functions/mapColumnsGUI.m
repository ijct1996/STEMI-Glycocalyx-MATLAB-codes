function mapping = mapColumnsGUI(headers, varargin)
%MAPCOLUMNSGUI Map spreadsheet columns to Time, Age, Sex, and data variables.

    p = inputParser;
    addParameter(p, 'RequireTime', true, @islogical);
    addParameter(p, 'MapDemographics', true, @islogical);
    addParameter(p, 'PromptTitle', 'STEMI column mapping', @(x) ischar(x) || isstring(x));
    parse(p, varargin{:});
    requireTime = p.Results.RequireTime;
    mapDemographics = p.Results.MapDemographics;
    promptTitle = char(string(p.Results.PromptTitle));

    headers = cellItems(headers);
    if isempty(headers)
        error('mapColumnsGUI:EmptyHeaders', 'No columns available to map.');
    end

    mapping = struct('timeCol', '', 'ageCol', '', 'sexCol', '', 'dataCols', {{}});
    reserved = {};

    if requireTime
        timeChoice = selectOneColumnGUI(headers, promptTitle, ...
            'Select the Time column (clock time, e.g. hh:mm):', false);
        if strlength(timeChoice) == 0
            error('mapColumnsGUI:Cancelled', 'Column mapping cancelled.');
        end
        mapping.timeCol = char(timeChoice);
        reserved = cellItems(mapping.timeCol);
    end

    if mapDemographics
        ageChoice = selectOneColumnGUI(headers, promptTitle, ...
            'Select the Age column (optional; choose <none> to skip):', true);
        if strlength(ageChoice) == 0
            error('mapColumnsGUI:Cancelled', 'Column mapping cancelled.');
        end
        if ~strcmp(char(ageChoice), '<none>')
            mapping.ageCol = char(ageChoice);
            reserved = cellItems(reserved, mapping.ageCol);
        end

        sexChoice = selectOneColumnGUI(headers, promptTitle, ...
            'Select the Sex column (optional; choose <none> to skip):', true);
        if strlength(sexChoice) == 0
            error('mapColumnsGUI:Cancelled', 'Column mapping cancelled.');
        end
        if ~strcmp(char(sexChoice), '<none>')
            mapping.sexCol = char(sexChoice);
            reserved = cellItems(reserved, mapping.sexCol);
        end
    end

    dataChoices = selectMultipleColumnsGUI(headers, reserved, promptTitle, ...
        'Select data columns for analysis:');
    if isempty(dataChoices)
        error('mapColumnsGUI:Cancelled', 'Column mapping cancelled.');
    end

    mapping.dataCols = cellstr(dataChoices);
end
