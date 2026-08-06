function [stemiPath, T, outRoot, mapping, setLabel] = resolveAnalysisSession(varargin)
%RESOLVEANALYSISSESSION Resolve data file, output folder, and column mapping.
%
%   Uses a JSON config when ConfigFile is provided and non-empty; otherwise
%   falls back to the interactive GUIs used in the lab workflow.
%
%   Name-value options:
%     ConfigFile       - path to JSON config ('' = interactive)
%     RequireTime      - require a time column (default true)
%     MapDemographics  - allow age/sex mapping (default true)
%     NeedSetLabel     - ask for / require setLabel (default false)
%     PromptTitle      - GUI window title
%     DefaultSetLabel  - fallback label when NeedSetLabel is true

    p = inputParser;
    addParameter(p, 'ConfigFile', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'RequireTime', true, @islogical);
    addParameter(p, 'MapDemographics', true, @islogical);
    addParameter(p, 'NeedSetLabel', false, @islogical);
    addParameter(p, 'PromptTitle', 'STEMI column mapping', @(x) ischar(x) || isstring(x));
    addParameter(p, 'DefaultSetLabel', 'core8', @(x) ischar(x) || isstring(x));
    parse(p, varargin{:});

    configFile = strtrim(char(string(p.Results.ConfigFile)));
    requireTime = p.Results.RequireTime;
    mapDemographics = p.Results.MapDemographics;
    needSetLabel = p.Results.NeedSetLabel;
    promptTitle = char(string(p.Results.PromptTitle));
    defaultSetLabel = char(string(p.Results.DefaultSetLabel));

    useConfig = ~isempty(configFile);
    cfg = struct();
    if useConfig
        cfg = loadAnalysisConfig(configFile);
        fprintf('Using config: %s\n', configFile);
    end

    % --- STEMI table ---
    if useConfig && ~isempty(cfg.stemiFile)
        stemiPath = cfg.stemiFile;
        if ~isfile(stemiPath)
            error('resolveAnalysisSession:MissingSTEMIFile', ...
                'STEMI file from config not found: %s', stemiPath);
        end
        T = readtable(stemiPath, 'VariableNamingRule', 'preserve');
        if isempty(T) || width(T) == 0
            error('resolveAnalysisSession:EmptyFile', ...
                'STEMI file is empty or unreadable: %s', stemiPath);
        end
        [~, fn, ext] = fileparts(stemiPath);
        fprintf('Loaded STEMI file: %s%s (%d rows, %d columns)\n', fn, ext, height(T), width(T));
    else
        [stemiPath, T] = loadSTEMITable();
    end

    % --- output folder ---
    if useConfig && ~isempty(cfg.outputFolder)
        outRoot = cfg.outputFolder;
        ensureDir(outRoot);
    else
        outRoot = selectOutputFolder(sprintf('Select output folder (%s)', promptTitle));
    end

    % --- column mapping ---
    headers = T.Properties.VariableNames;
    if useConfig && ~isempty(cfg.dataCols)
        mapping = struct( ...
            'timeCol', cfg.timeCol, ...
            'ageCol', cfg.ageCol, ...
            'sexCol', cfg.sexCol, ...
            'dataCols', {cfg.dataCols});

        if requireTime
            if isempty(mapping.timeCol)
                error('resolveAnalysisSession:MissingTimeCol', ...
                    'Config requires timeCol when RequireTime is true.');
            end
            assertColumnExists(headers, mapping.timeCol, 'timeCol');
        else
            mapping.timeCol = '';
        end

        if ~mapDemographics
            mapping.ageCol = '';
            mapping.sexCol = '';
        else
            if ~isempty(mapping.ageCol)
                assertColumnExists(headers, mapping.ageCol, 'ageCol');
            end
            if ~isempty(mapping.sexCol)
                assertColumnExists(headers, mapping.sexCol, 'sexCol');
            end
        end

        for i = 1:numel(mapping.dataCols)
            assertColumnExists(headers, mapping.dataCols{i}, sprintf('dataCols{%d}', i));
        end
    else
        mapping = mapColumnsGUI(headers, ...
            'RequireTime', requireTime, ...
            'MapDemographics', mapDemographics, ...
            'PromptTitle', promptTitle);
    end

    % --- set label (PCA / correlations) ---
    setLabel = '';
    if needSetLabel
        if useConfig && ~isempty(cfg.setLabel)
            setLabel = cfg.setLabel;
        else
            setLabel = input('Enter a short label for this variable set (e.g. core8): ', 's');
            if isempty(strtrim(setLabel))
                setLabel = defaultSetLabel;
            end
        end
        setLabel = matlab.lang.makeValidName(setLabel);
    end
end

function assertColumnExists(headers, colName, fieldName)
    headers = cellstr(string(headers(:)));
    colName = char(string(colName));
    if ~any(strcmp(headers, colName))
        error('resolveAnalysisSession:UnknownColumn', ...
            'Column "%s" (%s) not found in the STEMI table. Edit the config to match your headers.', ...
            colName, fieldName);
    end
end
