#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4  # Ensure this matches n_threads below
#SBATCH --time=24:00:00
#SBATCH --job-name=analysis_part2
#SBATCH --partition=debug
#SBATCH --error=/home/kcrc915/BugSeqer/qiime2/second_analysis/script_output/err_%j.out
#SBATCH --output=/home/kcrc915/BugSeqer/qiime2/second_analysis/script_output/std_%j.out

set -e  # Stop script if any command fails

# Declare important local variables
p_trim_left_f=5
p_trim_left_r=5
p_trunc_len_f=150
p_trunc_len_r=150

n_threads=4  # Match SLURM settings

#module load qiime2/2021.4

# Activate the qiime2 environment
source /home/kcrc915/miniconda3/bin/activate qiime2-2021.4 || { echo "QIIME2 activation failed"; exit 1; }

cd /home/kcrc915/BugSeqer/qiime2/second_analysis/

# Full path to manifest file
MANIFEST_PATH="/home/kcrc915/BugSeqer/qiime2/manifest"
if [ ! -f "$MANIFEST_PATH" ]; then
    echo "Manifest file not found at $MANIFEST_PATH!"
    exit 1
fi

# Check input files
for file in /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/paired-end-demux-trimmed.qza \
            /home/kcrc915/BugSeqer/qiime2/silva-138-99-515-806-nb-classifier.qza \
            /home/kcrc915/BugSeqer/qiime2/second_analysis/metadata.tsv; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file $file not found!"
        exit 1
    fi
done

echo "Starting dada2: $(date)"

qiime dada2 denoise-paired \
    --i-demultiplexed-seqs /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/paired-end-demux-trimmed.qza \
    --p-trunc-len-f $p_trunc_len_f \
    --p-trunc-len-r $p_trunc_len_r \
    --p-n-threads $n_threads \
    --o-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/table.qza \
    --o-representative-sequences /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/rep-seqs.qza \
    --o-denoising-stats /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/denoising-stats.qza

echo "dada2 complete: $(date)"

echo "denaoising visualization started at: $(date)"


qiime metadata tabulate \
       --m-input-file /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/denoising-stats.qza \
       --o-visualization /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/denoising-stats-viz.qzv
echo "Finished at: $(date)"

echo "filtered-table.qza started at: $(date)"

qiime feature-table filter-samples \
    --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/table.qza \
    --m-metadata-file /home/kcrc915/BugSeqer/qiime2/second_analysis/metadata.tsv \
    --o-filtered-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/filtered-table.qza  # Changed output name
echo "Finished at: $(date)"
echo "table-viz.qzv  started at: $(date)"
qiime feature-table summarize \
    --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/filtered-table.qza \
    --o-visualization /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/table-viz.qzv \
    --m-sample-metadata-file /home/kcrc915/BugSeqer/qiime2/second_analysis/metadata.tsv
echo "Finished at: $(date)"
echo "rep-seqs.qzv  started at: $(date)"

qiime feature-table tabulate-seqs \
    --i-data /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/rep-seqs.qza \
    --o-visualization /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/rep-seqs.qzv
echo "Finished at: $(date)"

echo "$(date) - Starting mafft fasttree and diversity operations"

qiime phylogeny align-to-tree-mafft-fasttree \
    --i-sequences /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/rep-seqs.qza \
    --o-alignment /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/aligned-rep-seqs.qza \
    --o-masked-alignment /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/masked-aligned-rep-seqs.qza \
    --o-tree /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/unrooted-tree.qza \
    --o-rooted-tree /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/rooted-tree.qza

qiime feature-classifier classify-sklearn \
    --i-classifier /home/kcrc915/BugSeqer/qiime2/silva-138-99-515-806-nb-classifier.qza \
    --i-reads /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/rep-seqs.qza \
    --o-classification  /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxonomy.qza

qiime metadata tabulate \
    --m-input-file /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxonomy.qza \
    --o-visualization /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxonomy.qzv

# Filter out eukarya and archaea
qiime taxa filter-table \
    --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/filtered-table.qza \
    --i-taxonomy /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxonomy.qza \
    --p-exclude eukarya,archaea \
    --o-filtered-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/final-table.qza  # Use a new name

qiime taxa barplot \
    --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/final-table.qza \
    --i-taxonomy /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxonomy.qza \
    --m-metadata-file /home/kcrc915/BugSeqer/qiime2/second_analysis/metadata.tsv \
    --o-visualization /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxa-bar-plots.qzv

echo "Analysis complete: $(date)"

