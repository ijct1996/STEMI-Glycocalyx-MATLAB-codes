# Methods notes (reproducibility)

Summary of the analysis logic in this package, aligned with the manuscript Methods.

## Cohort and exposure

- Retrospective secondary time-of-day analysis of first-onset STEMI (n = 63 in the source cohort).
- Temporal exposure: clock time of blood sampling during emergency PCI (decimal hours, 0–24).
- STEMI-only analyses (morning-only healthy controls from the source study are not analysed here).

## Time bins (Fig. 1)

- Four contiguous 6 h bins (see README).
- Per variable: exclude non-finite values and rows with missing/unparseable time.
- Omnibus: Kruskal–Wallis across bins.
- Multiple testing: Benjamini–Hochberg FDR across omnibus tests.
- Post hoc: Dunn–Sidak pairwise comparisons; significant pairs shown as brackets on box plots.
- Figures: one box plot per variable (900 DPI JPEG).

## 24 h cosinor (Fig. 2)

- Single-harmonic 24 h cosinor (mesor, amplitude, acrophase).
- Rhythm detection: zero-amplitude test vs flat mean; BH FDR across cosinor *p*-values.
- Fit summarised with R² (and related metrics in the Excel export).
- Figures: points vs clock time with fitted cosine when BH-significant (else null line); 900 DPI JPEG.

## PCA (Fig. 3)

- Core-8 variables (see README); complete-case rows; z-standardisation before PCA.
- PC1/PC2 score plot (coloured by time bin) + loadings heatmap.
- Export modes: Dev = 150 DPI PNG; Publication = 600 DPI JPEG.
- Loadings labels strip units except **Discharge (days)**; EF shown as “Ejection Fraction”.

## Spearman correlations (Fig. 4)

- Pairwise Spearman with pairwise-complete observations.
- Two-sided tests; BH FDR across pairs.
- Heatmap of ρ with significance markers after BH (900 DPI JPEG).

## Software

- MATLAB R2025b (or compatible); Statistics and Machine Learning Toolbox.
- `rng(1)` at script start (reproducible jitter where used).
- Visual abstract (BioRender) is outside this package.

## Data governance

Patient-level Excel files are **not** included. Map columns via `config/publication_core8.json` or the interactive GUIs.
