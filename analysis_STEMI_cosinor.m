%% analysis_STEMI_cosinor.m
% STEMI 24 h cosinor analysis (manuscript Fig. 2).
%
% Outputs per selected variable:
%   - Individual 24 h cosinor figure (900 DPI JPEG)
%   - Excel QC and results tables with BH/FDR on zero-amplitude p-values
%
% Optional non-interactive config: edit CONFIG_FILE below (or set to '').

clear;
clc;
close all;
rng(1);

paths = setup_paths();
fprintf('\n=== STEMI 24 h cosinor analysis ===\n');

CONFIG_FILE = fullfile(paths.projectRoot, 'config', 'publication_core8.json');

[stemiPath, T, outRoot, mapping] = resolveAnalysisSession( ...
    'ConfigFile', CONFIG_FILE, ...
    'RequireTime', true, ...
    'MapDemographics', true, ...
    'NeedSetLabel', false, ...
    'PromptTitle', 'STEMI cosinor: column mapping');

figDir = fullfile(outRoot, 'Figures');
tblDir = fullfile(outRoot, 'Tables');
ensureDir(figDir);
ensureDir(tblDir);

hours = parseTimeToHours(getTableColumn(T, mapping.timeCol));
hours = mod(hours, 24);

wb = fullfile(tblDir, 'STEMI_Cosinor_Results.xlsx');
resetWorkbook(wb);

QCTbl = table('Size', [0 9], ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'string', 'string'}, ...
    'VariableNames', {'Variable', 'N_Total', 'N_Usable', 'N_Missing', 'N_UniqueTimes', 'Y_Min', 'Y_Max', 'Status', 'Note'});

ResultsTbl = table('Size', [0 15], ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'string', 'string'}, ...
    'VariableNames', {'Variable', 'N_Usable', 'Mesor', 'Amplitude', 'Acrophase_h', 'Acrophase_deg', ...
                      'p_ZeroAmplitude', 'R2_Cosinor', 'AdjR2_Cosinor', 'AIC_Null', 'AIC_Cosinor', ...
                      'BIC_Null', 'BIC_Cosinor', 'BestModel', 'Status'});

FigureJobs = struct('fileStem', {}, 'yLabel', {}, 't', {}, 'y', {}, 'fitOut', {}, 'resultRow', {});

for i = 1:numel(mapping.dataCols)
    colName = mapping.dataCols{i};
    info = parseColumnLabel(colName);

    yRaw = toNumericFlexible(getTableColumn(T, colName), colName);
    yRaw = yRaw(:);

    nTotal = numel(yRaw);
    ok = usableRowMask(yRaw, hours);
    t = hours(ok);
    y = yRaw(ok);

    nUsable = numel(y);
    nMissing = nTotal - nUsable;
    nUniqueTimes = numel(unique(round(t, 6)));
    yMin = NaN;
    yMax = NaN;
    if ~isempty(y)
        yMin = min(y);
        yMax = max(y);
    end

    if nUsable < 6
        QCTbl = [QCTbl; {info.displayLabel, nTotal, nUsable, nMissing, nUniqueTimes, yMin, yMax, "Skipped", "Too few usable observations (<6)."}]; %#ok<AGROW>
        continue;
    end
    if nUniqueTimes < 4
        QCTbl = [QCTbl; {info.displayLabel, nTotal, nUsable, nMissing, nUniqueTimes, yMin, yMax, "Skipped", "Too few unique time points (<4)."}]; %#ok<AGROW>
        continue;
    end
    if numel(unique(y)) < 3
        QCTbl = [QCTbl; {info.displayLabel, nTotal, nUsable, nMissing, nUniqueTimes, yMin, yMax, "Skipped", "Too little outcome variation."}]; %#ok<AGROW>
        continue;
    end

    fitOut = fitSimple24hCosinor(t, y);
    if ~fitOut.ok
        QCTbl = [QCTbl; {info.displayLabel, nTotal, nUsable, nMissing, nUniqueTimes, yMin, yMax, "Failed", string(fitOut.note)}]; %#ok<AGROW>
        continue;
    end

    QCTbl = [QCTbl; {info.displayLabel, nTotal, nUsable, nMissing, nUniqueTimes, yMin, yMax, "Completed", "Pending BH/FDR."}]; %#ok<AGROW>
    ResultsTbl = [ResultsTbl; {info.displayLabel, nUsable, fitOut.mesor, fitOut.amplitude, fitOut.acrophase_h, ...
        fitOut.acrophase_deg, fitOut.pZeroAmplitude, fitOut.R2Cos, fitOut.AdjR2Cos, fitOut.AICNull, fitOut.AICCos, ...
        fitOut.BICNull, fitOut.BICCos, "PendingBH", "Completed"}]; %#ok<AGROW>

    resultRow = height(ResultsTbl);
    FigureJobs(end + 1) = struct( ... %#ok<SAGROW>
        'fileStem', info.fileStem, ...
        'yLabel', char(info.yLabel), ...
        't', t, ...
        'y', y, ...
        'fitOut', fitOut, ...
        'resultRow', resultRow);
end

if ~isempty(ResultsTbl)
    [BHFDR, pBH] = makeBHWorkflowTable(ResultsTbl.Variable + " | p_ZeroAmplitude", ResultsTbl.p_ZeroAmplitude);
    writetable(BHFDR, wb, 'Sheet', 'BH_FDR_Cosinor');

    sigBH = isfinite(pBH) & pBH < 0.05;
    ResultsTbl.BestModel(:) = "NullLine";
    ResultsTbl.BestModel(sigBH) = "Cosinor";

    ResultsBH = ResultsTbl;
    ResultsBH.p_ZeroAmplitude_BH = pBH;
    ResultsBH.Significant_BH = sigBH;
    writetable(ResultsBH, wb, 'Sheet', 'Results_BH');

    for jj = 1:numel(FigureJobs)
        rowIdx = FigureJobs(jj).resultRow;
        fitOutBH = FigureJobs(jj).fitOut;
        fitOutBH.isRhythmic = isfinite(pBH(rowIdx)) && pBH(rowIdx) < 0.05;

        outFig = fullfile(figDir, sprintf('%s_Cosinor_24h.jpg', FigureJobs(jj).fileStem));
        plotCosinor24h(FigureJobs(jj).t, FigureJobs(jj).y, fitOutBH, FigureJobs(jj).yLabel, outFig);
        fprintf('Saved figure: %s\n', outFig);
    end
end

writetable(QCTbl, wb, 'Sheet', 'QC_Summary');
writetable(ResultsTbl, wb, 'Sheet', 'Results');

writeRunLog(outRoot, 'analysis_STEMI_cosinor', struct( ...
    'stemiFile', stemiPath, ...
    'timeColumn', mapping.timeCol, ...
    'dataColumns', mapping.dataCols, ...
    'outputRoot', outRoot));

fprintf('\nDone. Cosinor outputs written to:\n  %s\n', outRoot);
