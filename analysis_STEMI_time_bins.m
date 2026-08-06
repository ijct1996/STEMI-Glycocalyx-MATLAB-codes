%% analysis_STEMI_time_bins.m
% STEMI time-of-day box plots by predefined time bins (manuscript Fig. 1).
%
% NaN, empty cells, and common missing tokens (NA, N/A, etc.) are excluded
% per variable. Rows with missing or unparseable clock time are also skipped.
%   - One 900 DPI JPEG box plot per selected variable
%   - Excel summary with Kruskal-Wallis p-values and BH/FDR correction
%
% MATLAB toolboxes: Statistics and Machine Learning Toolbox
%
% Optional non-interactive config: edit CONFIG_FILE below (or set to '').

clear;
clc;
close all;
rng(1);

paths = setup_paths();
fprintf('\n=== STEMI time-bin box plots ===\n');

% Set to '' to force interactive file/folder/column GUIs.
CONFIG_FILE = fullfile(paths.projectRoot, 'config', 'publication_core8.json');

[stemiPath, T, outRoot, mapping] = resolveAnalysisSession( ...
    'ConfigFile', CONFIG_FILE, ...
    'RequireTime', true, ...
    'MapDemographics', true, ...
    'NeedSetLabel', false, ...
    'PromptTitle', 'STEMI time-bin analysis: column mapping');

figDir = fullfile(outRoot, 'Figures');
tblDir = fullfile(outRoot, 'Tables');
ensureDir(figDir);
ensureDir(tblDir);

hours = parseTimeToHours(getTableColumn(T, mapping.timeCol));
hours = mod(hours, 24);
[binNames, binCols] = getTimeBinPalette();
timeBin = makeTimeBins(hours, binNames);

wb = fullfile(tblDir, 'STEMI_TimeBins_Results.xlsx');
resetWorkbook(wb);

Summary = table('Size', [0 10], ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Variable', 'N_Total', 'N_Missing', 'N_Usable', 'KW_p', 'N_Morning', 'N_Afternoon', 'N_Evening', 'N_Night', 'HasFigure'});

qcAll = variableMissingQC(T, mapping.dataCols);
writetable(qcAll, wb, 'Sheet', 'QC_MissingValues');

for i = 1:numel(mapping.dataCols)
    colName = mapping.dataCols{i};
    info = parseColumnLabel(colName);
    y = toNumericFlexible(getTableColumn(T, colName), colName);

    nTotal = numel(y);
    idx = usableRowMask(y, hours, timeBin);
    y2 = y(idx);
    b2 = timeBin(idx);
    nUsable = numel(y2);
    nMissing = nTotal - sum(isfinite(y));

    nMorning = sum(string(b2) == "Morning");
    nAfternoon = sum(string(b2) == "Afternoon");
    nEvening = sum(string(b2) == "Evening");
    nNight = sum(string(b2) == "Night");

    if nUsable < 8 || numel(categories(removecats(b2))) < 2 || numel(unique(y2)) < 2
        Summary = [Summary; {info.displayLabel, nTotal, nMissing, nUsable, NaN, nMorning, nAfternoon, nEvening, nNight, 0}]; %#ok<AGROW>
        fprintf('Skipped %s: insufficient usable data after excluding NaN/missing (N=%d).\n', info.displayLabel, nUsable);
        continue;
    end

    [pKW, ~, statsKW] = kruskalwallis(y2, b2, 'off');

    sigPairs = [];
    sigP = [];
    try
        c = multcompare(statsKW, 'CType', 'dunn-sidak', 'Display', 'off');
        posthocTbl = array2table(c, 'VariableNames', ...
            {'Group1', 'Group2', 'Lower', 'Estimate', 'Upper', 'pValue'});
        gnames = string(statsKW.gnames(:));
        posthocTbl.Bin1 = categorical(gnames(posthocTbl.Group1), binNames, 'Ordinal', true);
        posthocTbl.Bin2 = categorical(gnames(posthocTbl.Group2), binNames, 'Ordinal', true);
        phOut = posthocTbl(:, {'Bin1', 'Bin2', 'Lower', 'Estimate', 'Upper', 'pValue'});
        writetable(phOut, wb, 'Sheet', safeSheetName(sprintf('%s_PostHoc', info.fileStem)));

        isSig = phOut.pValue < 0.05;
        if any(isSig)
            xMap = containers.Map(cellstr(binNames), num2cell(1:numel(binNames)));
            b1s = string(phOut.Bin1(isSig));
            b2s = string(phOut.Bin2(isSig));
            sigPairs = zeros(sum(isSig), 2);
            for k = 1:sum(isSig)
                sigPairs(k, 1) = xMap(char(b1s(k)));
                sigPairs(k, 2) = xMap(char(b2s(k)));
            end
            sigP = phOut.pValue(isSig);
        end
    catch
    end

    outFig = fullfile(figDir, sprintf('%s_TimeBins_BoxPlot.jpg', info.fileStem));
    plotSTEMITimeBinBoxplot(y2, b2, binNames, binCols, info.yLabel, outFig, sigPairs, sigP, info.fileStem);

    Summary = [Summary; {info.displayLabel, nTotal, nMissing, nUsable, pKW, nMorning, nAfternoon, nEvening, nNight, 1}]; %#ok<AGROW>
    fprintf('Saved figure: %s\n', outFig);
end

writetable(Summary, wb, 'Sheet', 'Summary');
[BHFDR, ~] = makeBHWorkflowTable(Summary.Variable + " | KW omnibus", Summary.KW_p);
writetable(BHFDR, wb, 'Sheet', safeSheetName('BH_FDR_KW_Omnibus'));

writeRunLog(outRoot, 'analysis_STEMI_time_bins', struct( ...
    'stemiFile', stemiPath, ...
    'timeColumn', mapping.timeCol, ...
    'dataColumns', mapping.dataCols, ...
    'outputRoot', outRoot));

fprintf('\nDone. Outputs written to:\n  %s\n', outRoot);
