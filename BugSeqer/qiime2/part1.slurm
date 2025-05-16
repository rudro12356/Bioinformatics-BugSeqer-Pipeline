#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4

#SBATCH --time=12:00:00
#SBATCH --job-name=analysis_part1
#SBATCH --partition=debug
#SBATCH --error=/home/kcrc915/BugSeqer/qiime2/second_analysis/script_output/err.out
#SBATCH --output=/home/kcrc915/BugSeqer/qiime2/second_analysis/script_output/std.out
#SBATCH --open-mode=append

##########################################################################
# Import the data into QIIME2, summarize using demux
# Trim adapter sequences using cutadapt, then summarize it
##########################################################################

# Activate the qiime2 environment
source /home/kcrc915/miniconda3/bin/activate qiime2-2021.4

# Change to the working directory
cd /home/kcrc915/BugSeqer/qiime2/second_analysis/

mkdir -p artifacts
mkdir -p exports

# Full path to the manifest file
MANIFEST_PATH="/home/kcrc915/BugSeqer/qiime2/manifest"

# Ensure the manifest file exists
if [ ! -f "$MANIFEST_PATH" ]; then
    echo "Manifest file not found at $MANIFEST_PATH!"
    exit 1
fi

# Import data into QIIME2
qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path "$MANIFEST_PATH" \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path artifacts/demuxed-paired-end.qza

# Check if import was successful
if [ ! -f ./artifacts/demuxed-paired-end.qza ]; then
    echo "Failed to create artifact 'demuxed-paired-end.qza'"
    exit 1
fi

# Summarize the imported data
qiime demux summarize \
    --i-data ./artifacts/demuxed-paired-end.qza \
    --o-visualization ./artifacts/demux.qzv

# Trim adapter sequences using cutadapt
qiime cutadapt trim-paired \
    --i-demultiplexed-sequences ./artifacts/demuxed-paired-end.qza \
    --p-front-f CCTACGGGNGGCWGCAG \
    --p-front-r GACTACHVGGGTATCTAATCC \
    --o-trimmed-sequences ./artifacts/paired-end-demux-trimmed.qza \
    --verbose > cutadapt_log.txt

# Check if the trim process was successful
if [ ! -f ./artifacts/paired-end-demux-trimmed.qza ]; then
    echo "Failed to create artifact 'paired-end-demux-trimmed.qza'"
    exit 1
fi

# Summarize the trimmed sequences
qiime demux summarize \
    --i-data ./artifacts/paired-end-demux-trimmed.qza \
    --o-visualization ./artifacts/paired-end-demux-trimmed.qzv

