function cfg = loadAnalysisConfig(configFile)
%LOADANALYSISCONFIG Load a JSON analysis config for non-interactive runs.
%
%   Expected fields (all optional except dataCols when used):
%     stemiFile, outputFolder, setLabel, timeCol, ageCol, sexCol, dataCols

    if nargin < 1 || strlength(string(configFile)) == 0
        error('loadAnalysisConfig:EmptyPath', 'Config file path is empty.');
    end

    configFile = char(string(configFile));
    if ~isfile(configFile)
        error('loadAnalysisConfig:MissingFile', 'Config file not found: %s', configFile);
    end

    txt = fileread(configFile);
    cfg = jsondecode(txt);

    if ~isfield(cfg, 'stemiFile'); cfg.stemiFile = ''; end
    if ~isfield(cfg, 'outputFolder'); cfg.outputFolder = ''; end
    if ~isfield(cfg, 'setLabel'); cfg.setLabel = ''; end
    if ~isfield(cfg, 'timeCol'); cfg.timeCol = ''; end
    if ~isfield(cfg, 'ageCol'); cfg.ageCol = ''; end
    if ~isfield(cfg, 'sexCol'); cfg.sexCol = ''; end
    if ~isfield(cfg, 'dataCols'); cfg.dataCols = {}; end

    cfg.stemiFile = char(string(cfg.stemiFile));
    cfg.outputFolder = char(string(cfg.outputFolder));
    cfg.setLabel = char(string(cfg.setLabel));
    cfg.timeCol = char(string(cfg.timeCol));
    cfg.ageCol = char(string(cfg.ageCol));
    cfg.sexCol = char(string(cfg.sexCol));

    if isstring(cfg.dataCols) || ischar(cfg.dataCols)
        cfg.dataCols = cellstr(string(cfg.dataCols));
    elseif iscell(cfg.dataCols)
        cfg.dataCols = cellstr(string(cfg.dataCols(:)));
    else
        cfg.dataCols = {};
    end
end
