%% analysis_STEMI_correlations.m
% STEMI Spearman correlation matrix (manuscript Fig. 4; core-8 set).
%
% Pairwise Spearman uses only rows where both variables are finite (NaN skipped).
%   - Spearman heatmap (900 DPI JPEG)
%   - Excel tables with rho, raw p, BH-adjusted p, and pairwise N
%
% Optional non-interactive config: edit CONFIG_FILE below (or set to '').

clear;
clc;
close all;
rng(1);

paths = setup_paths();
fprintf('\n=== STEMI Spearman correlations ===\n');

minCorrN = 6;

CONFIG_FILE = fullfile(paths.projectRoot, 'config', 'publication_core8.json');

[stemiPath, T, outRoot, mapping, setLabel] = resolveAnalysisSession( ...
    'ConfigFile', CONFIG_FILE, ...
    'RequireTime', false, ...
    'MapDemographics', false, ...
    'NeedSetLabel', true, ...
    'DefaultSetLabel', 'core8', ...
    'PromptTitle', 'STEMI correlations: select data columns');

outSet = fullfile(outRoot, ['Correlations_' setLabel]);
figDir = fullfile(outSet, 'Figures');
tblDir = fullfile(outSet, 'Tables');
ensureDir(figDir);
ensureDir(tblDir);

dataCols = mapping.dataCols;
nVars = numel(dataCols);
labels = strings(nVars, 1);
M = nan(height(T), nVars);

for j = 1:nVars
    info = parseColumnLabel(dataCols{j});
    labels(j) = info.name;
    M(:, j) = toNumericFlexible(getTableColumn(T, dataCols{j}), dataCols{j});
end

[R, P, N] = pairwiseSpearman(M, minCorrN);
[Pbh, BHFDR] = bhAdjustSymmetricP(P, labels);

wb = fullfile(tblDir, sprintf('Spearman_%s_Results.xlsx', setLabel));
resetWorkbook(wb);

qcAll = variableMissingQC(T, dataCols);
writetable(qcAll, wb, 'Sheet', 'QC_MissingValues');

Tbl = corrLongTable(labels, R, P, N, minCorrN);
if ~isempty(BHFDR)
    pairKey = Tbl.Var1 + " vs " + Tbl.Var2;
    bhKey = BHFDR.VariableOrTest;
    pAdj = nan(height(Tbl), 1);
    for r = 1:height(Tbl)
        hit = find(bhKey == pairKey(r), 1);
        if ~isempty(hit)
            pAdj(r) = BHFDR.BH_Adjusted(hit);
        end
    end
    Tbl.pValue_BH = pAdj;
    Tbl.Significant_BH = isfinite(pAdj) & pAdj < 0.05;
end

figPath = fullfile(figDir, sprintf('Spearman_%s.jpg', setLabel));
plotSpearmanHeatmap(R, Pbh, cellstr(labels), figPath);

writetable(Tbl, wb, 'Sheet', 'PairwiseCorrelations');
writetable(BHFDR, wb, 'Sheet', safeSheetName('BH_FDR'));

writeRunLog(outSet, 'analysis_STEMI_correlations', struct( ...
    'stemiFile', stemiPath, ...
    'variableSetLabel', setLabel, ...
    'dataColumns', dataCols, ...
    'minPairwiseN', minCorrN, ...
    'figure', figPath));

fprintf('\nDone. Correlation outputs written to:\n  %s\n', outSet);
