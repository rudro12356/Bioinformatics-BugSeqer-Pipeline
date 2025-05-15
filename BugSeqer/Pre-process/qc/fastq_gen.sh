#!/bin/bash

# Define the raw reads directory and the QC output directory
RAW_READS_DIR="/home/kcrc915/BugSeqer/Raw_Reads/raw_reads"
QC_DIR="/home/kcrc915/BugSeqer/Pre-process/qc"
FASTQC_BIN="/home/kcrc915/miniconda3/bin/fastqc"

# Loop through all fastq files in the RAW_READS_DIR
for fq1 in "$RAW_READS_DIR"/*_1.fastq; do
    fq2="${fq1/_1.fastq/_2.fastq}"

    # Check if both paired files exist
    if [[ -f "$fq1" && -f "$fq2" ]]; then
        echo "Running FastQC for $fq1 and $fq2..."
        
        # Run FastQC and redirect output to stdout and stderr
        "$FASTQC_BIN" "$fq1" -o "$QC_DIR" >> /home/kcrc915/BugSeqer/Pre-process/qc/std.out 2>> /home/kcrc915/BugSeqer/Pre-process/qc/err.out
        "$FASTQC_BIN" "$fq2" -o "$QC_DIR" >> /home/kcrc915/BugSeqer/Pre-process/qc/std.out 2>> /home/kcrc915/BugSeqer/Pre-process/qc/err.out
    else
        echo "FASTQ file pair missing for $fq1 or $fq2" >&2
    fi
done

echo "FastQC analysis completed."

/home/kcrc915/miniconda3/bin/multiqc /home/kcrc915/BugSeqer/Pre-process/qc -o /home/kcrc915/BugSeqer/Pre-process/qc/multiqc
