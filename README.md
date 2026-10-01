# STEMI glycocalyx time-of-day analysis

MATLAB code for the manuscript on time-of-day variation in complement activation and endothelial glycocalyx nanomechanics in ST-elevation myocardial infarction (STEMI).

**Patient-level data are not included** (ethics / institutional data-governance restrictions). 

---

## Repository layout

```text
publication_code/
├── analysis_STEMI_time_bins.m      # Fig. 1
├── analysis_STEMI_cosinor.m        # Fig. 2
├── analysis_STEMI_pca.m            # Fig. 3
├── analysis_STEMI_correlations.m   # Fig. 4
├── setup_paths.m                   # adds Functions/ to the MATLAB path
├── config/
│   └── publication_core8.json      # column map + optional file paths
├── Functions/                      # shared helpers (do not run directly)
├── docs/
│   └── METHODS.md                  # analysis logic summary
├── LICENSE                         # MIT
├── CITATION.cff
└── README.md
```

---

## Requirements

| Item | Detail |
|------|--------|
| MATLAB | R2025b recommended (recent releases should work) |
| Toolbox | Statistics and Machine Learning Toolbox |
| Paths | Open MATLAB **in this folder**; `setup_paths` adds only local `Functions/` |

No external Shared library or parent lab folder is required.

---

## Quick start

1. Open this folder in MATLAB.
2. Edit `config/publication_core8.json`:
   - Set `timeCol` and `dataCols` to **exact** Excel header strings.
   - Optionally set `stemiFile` and `outputFolder` to absolute paths for a non-interactive run.
   - Leave those paths empty to use file/folder dialogs while still using the column map.
3. Run one entry-point script (see table below).

To force interactive column-mapping GUIs instead of the JSON map, set near the top of the script:

```matlab
CONFIG_FILE = '';
```

---

## Manuscript figure map

| Script | Figure | Analysis |
|--------|--------|----------|
| `analysis_STEMI_time_bins.m` | **Fig. 1** | 6 h time-bin **box plots**; Kruskal–Wallis + BH FDR; Dunn–Sidak post hoc |
| `analysis_STEMI_cosinor.m` | **Fig. 2** | 24 h cosinor; zero-amplitude test + BH FDR |
| `analysis_STEMI_pca.m` | **Fig. 3** | PCA (z-scored complete cases); PC1/PC2 scores + loadings |
| `analysis_STEMI_correlations.m` | **Fig. 4** | Pairwise Spearman heatmap + BH FDR |

More detail: [`docs/METHODS.md`](docs/METHODS.md).

---

## Core-8 variables (Fig. 3–4)

Default set in `config/publication_core8.json` (edit headers to match your sheet):

1. Cortical stiffness  
2. Endothelial glycocalyx (eGC) height  
3. eGC stiffness  
4. Syndecan-1  
5. C3a  
6. C5a  
7. Discharge duration  
8. Ejection fraction  

Fig. 1–2 typically use the endothelial/inflammatory subset (with or without EF/discharge). Loadings heatmap order follows the order of columns in `dataCols` / your Excel selection order.

### Time bins (sampling clock time during emergency PCI)

| Bin | Clock time |
|-----|------------|
| Morning | 06:00 – &lt;12:00 |
| Afternoon | 12:00 – &lt;18:00 |
| Evening | 18:00 – &lt;24:00 |
| Night | 00:00 – &lt;06:00 |

---

## Outputs

Each run writes to a user-chosen folder:

| Output | Format |
|--------|--------|
| Figures | Time bins / cosinor / Spearman: **900 DPI JPEG**. PCA: Dev = **150 DPI PNG**; Publication = **600 DPI JPEG** (chosen in a GUI). |
| Tables | Excel workbooks (QC, *p*-values, BH FDR, loadings/scores as applicable) |
| Run log | Plain-text paths and mapped columns |

---

## Config template

Example fields in `config/publication_core8.json`:

```json
{
  "stemiFile": "",
  "outputFolder": "",
  "setLabel": "core8",
  "timeCol": "Time (hh:mm)",
  "ageCol": "",
  "sexCol": "",
  "dataCols": [ "...exact header strings..." ]
}
```

Headers must match the workbook **exactly** (including units in parentheses).

