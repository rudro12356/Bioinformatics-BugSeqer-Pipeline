# Bioinformatics-BugSeqer-Pipeline

## 16S rRNA Analysis Pipeline Execution Plan

### Step 1: Retrieve Sample Accession Numbers
1. Search for samples on the NCBI SRA portal: [https://www.ncbi.nlm.nih.gov/sra](https://www.ncbi.nlm.nih.gov/sra)
2. Identify and collect the SRA accession numbers (e.g., `SRR12345678`) relevant to your study (e.g., CRC vs. Healthy Volunteers).
3. Save the accession numbers in the following file:  
   `~/BugSeqer/Raw_Reads/SRR_Acc_List.txt`

### Step 2: Create Metadata File
1. For each sample:
   - Paste the SRR accession number into the NCBI search bar.
   - Click on the **BioSample** link from the results.
   - Identify the sample type (e.g., CRC, UK Control, Healthy Volunteer).
2. Create a `metadata.tsv` file manually, ensuring each sample is correctly mapped to its condition.

### Step 3: Prepare Raw FASTQ Files

#### Option A: Use Pre-downloaded Files
Ensure that all raw FASTQ files are stored in:  
`~/BugSeqer/Raw_Reads/raw_reads/`

#### Option B: Download FASTQ Files via Script
If raw reads are not yet downloaded, run the script:

```bash
bash get_fastq.sh
```

This script uses `SRR_Acc_List.txt` to download the appropriate FASTQ files.

### Step 4: Run the Pipeline
Execute the processing pipeline:

```bash
bash pipeline.sh
```

**Estimated runtime:** ~4 hours for 153 samples  
*(Note: Execution time depends on available memory and system performance.)*

---

## System Requirements
- Operating System: **Ubuntu** (recommended)
- Software Dependencies:
  - Python 2.7 or higher
  - QIIME 2 version 2021.4
  - LEfSe environment (`lefse-env`)
  - R with the following packages:
    - `tidyverse`
    - `qiime2R`

---

## Important Notes on Code Execution
- Most code files include hardcoded paths from my local environment (`/home/kcrc915/BugSeqer/...`).
- Please update all paths to reflect your local directory structure before running any scripts.
- Only the code and scripts are shared; due to the size (~40+ GB), results are hosted externally.

---

## Access to Results
You can view or download all generated results from the following SharePoint link:  
[SharePoint Results](https://kansas-my.sharepoint.com/:u:/g/personal/k164c194_home_ku_edu/EcEaULqySmhGn1ldC63j1kABD1eaEkIUOfN0UlhzHLhypg?e=f78h1K)

### Path to Results in Project Structure:
- All `.qza` files have been extracted and saved in their respective subdirectories.
- Visualizations and analysis outputs for artifacts are available under: `core-metrics-results/`
- To view visual summaries, open the corresponding `index.html` files using a browser.

---

## Reference
[https://github.com/clayton-lab/BugSeqer/tree/main](https://github.com/clayton-lab/BugSeqer/tree/main)
