%% analysis_STEMI_pca.m
% STEMI principal component analysis (manuscript Fig. 3; core-8 set).
%
% Outputs per variable set:
%   - Combined PC1/PC2 score plot (coloured by time bin) + loadings heatmap
%       Dev mode:         medium-quality PNG (150 DPI)
%       Publication mode: 600 DPI JPEG
%   - Excel workbook with explained variance, loadings, and scores
%
% Rows with NaN in any selected variable, missing clock time, or unassigned
% time bin are excluded (complete-case analysis).
%
% Optional non-interactive config: edit CONFIG_FILE below (or set to '').

clear;
clc;
close all;
rng(1);

paths = setup_paths();
fprintf('\n=== STEMI PCA ===\n');

exportMode = selectExportModeGUI( ...
    'Title', 'STEMI PCA: export mode', ...
    'Default', 'dev');
fprintf('Export mode: %s\n', exportMode.Label);

CONFIG_FILE = fullfile(paths.projectRoot, 'config', 'publication_core8.json');

[stemiPath, T, outRoot, mapping, setLabel] = resolveAnalysisSession( ...
    'ConfigFile', CONFIG_FILE, ...
    'RequireTime', true, ...
    'MapDemographics', true, ...
    'NeedSetLabel', true, ...
    'DefaultSetLabel', 'core8', ...
    'PromptTitle', 'STEMI PCA: column mapping');

hours = parseTimeToHours(getTableColumn(T, mapping.timeCol));
hours = mod(hours, 24);
[binNames, binCols] = getTimeBinPalette();
timeBin = makeTimeBins(hours, binNames);

dataCols = mapping.dataCols;
nVars = numel(dataCols);
if nVars < 2
    error('analysis_STEMI_pca:TooFewVariables', ...
        'Select at least 2 data columns for PCA.');
end
displayLabels = strings(nVars, 1);
varStems = strings(nVars, 1);
X = nan(height(T), nVars);

for j = 1:nVars
    info = parseColumnLabel(dataCols{j});
    varStems(j) = info.fileStem;
    X(:, j) = toNumericFlexible(getTableColumn(T, dataCols{j}), dataCols{j});
end
% Publication loadings labels: units stripped except Discharge (days);
% EF shown as "Ejection Fraction" (matches submitted PCA figure).
displayLabels = string(formatPcaPublicationLabels(dataCols));

outSet = fullfile(outRoot, ['PCA_' setLabel]);
figDir = fullfile(outSet, 'Figures');
tblDir = fullfile(outSet, 'Tables');
ensureDir(figDir);
ensureDir(tblDir);

nTotalRows = height(T);
idx = all(isfinite(X), 2) & isfinite(hours) & ~isundefined(timeBin);
nCompleteCases = sum(idx);
nExcluded = nTotalRows - nCompleteCases;

X = X(idx, :);
timeBinUse = timeBin(idx);
hourUse = hours(idx);

if size(X, 1) < 12
    error('analysis_STEMI_pca:InsufficientN', ...
        'Insufficient complete cases for PCA (%d). Need at least 12.', size(X, 1));
end

mu = mean(X, 1, 'omitnan');
sd = std(X, 0, 1, 'omitnan');
sd(sd == 0 | ~isfinite(sd)) = 1;
Xz = (X - mu) ./ sd;

try
    [coeff, score, latent, ~, explained] = pca(Xz, 'Centered', false);
catch
    [coeff, score, latent, ~, explained] = pca(Xz);
end

nPC = size(score, 2);
displayLabelCells = cellstr(displayLabels);

figPath = fullfile(figDir, sprintf('PCA_%s_Scores_Loadings%s', setLabel, exportMode.Extension));
figPaths = plotPcaPublication(score, explained, coeff, timeBinUse, binNames, binCols, displayLabelCells, figPath, ...
    'ExportMode', exportMode);
if ischar(figPaths) || isstring(figPaths)
    figPaths = cellstr(figPaths);
end
figPath = figPaths{1};

wb = fullfile(tblDir, sprintf('PCA_%s_Results.xlsx', setLabel));
resetWorkbook(wb);

qcAll = variableMissingQC(T, dataCols);
writetable(qcAll, wb, 'Sheet', 'QC_MissingValues');

qcComplete = table(nTotalRows, nCompleteCases, nExcluded, ...
    'VariableNames', {'N_Total', 'N_CompleteCases', 'N_Excluded_NaN_or_missing_time'});
writetable(qcComplete, wb, 'Sheet', 'QC_CompleteCases');

TblExpl = table((1:numel(explained))', explained(:), cumsum(explained(:)), latent(:), ...
    'VariableNames', {'PC', 'ExplainedPct', 'CumulativePct', 'Eigenvalue'});
writetable(TblExpl, wb, 'Sheet', 'ExplainedVariance');

loadTbl = array2table(coeff, 'VariableNames', compose('PC%d', 1:nPC));
loadTbl.Variable = displayLabels;
loadTbl.SourceColumn = string(dataCols(:));
loadTbl = movevars(loadTbl, {'Variable', 'SourceColumn'}, 'Before', 1);
writetable(loadTbl, wb, 'Sheet', 'Loadings');

scoreTbl = table(hourUse, timeBinUse, 'VariableNames', {'Hour', 'TimeBin'});
for kk = 1:nPC
    scoreTbl.(sprintf('PC%d', kk)) = score(:, kk);
end
writetable(scoreTbl, wb, 'Sheet', 'Scores');

inputTbl = array2table(X, 'VariableNames', cellstr(varStems));
inputTbl.Hour = hourUse;
inputTbl.TimeBin = timeBinUse;
inputTbl = movevars(inputTbl, {'Hour', 'TimeBin'}, 'Before', 1);
writetable(inputTbl, wb, 'Sheet', 'PCA_InputRaw');

writeRunLog(outSet, 'analysis_STEMI_pca', struct( ...
    'stemiFile', stemiPath, ...
    'variableSetLabel', setLabel, ...
    'timeColumn', mapping.timeCol, ...
    'dataColumns', {dataCols}, ...
    'completeCaseN', size(X, 1), ...
    'excludedRows', nExcluded, ...
    'exportMode', exportMode.Name, ...
    'exportFormat', exportMode.Format, ...
    'exportDpi', exportMode.Resolution, ...
    'figures', {figPaths}));

fprintf('\nDone. PCA outputs written to:\n  %s\n', outSet);
fprintf('Figure export: %s\n', exportMode.Label);
for ii = 1:numel(figPaths)
    fprintf('  Figure: %s\n', figPaths{ii});
end
fprintf('Complete cases used: %d / %d (excluded %d rows with NaN or missing time).\n', ...
    nCompleteCases, nTotalRows, nExcluded);
