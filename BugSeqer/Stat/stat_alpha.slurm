#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=6:00:00  # Extended runtime for full analysis
#SBATCH --job-name=full_diversity
#SBATCH --partition=debug
#SBATCH --error=/home/kcrc915/BugSeqer/qiime2/stat/script_output/full_err.out
#SBATCH --output=/home/kcrc915/BugSeqer/qiime2/stat/script_output/full_out.out

# ======================
# 1. LOAD QIIME2 ENVIRONMENT
# ======================
# Option 1: Module system
#module load qiime2/2021.4

# Option 2: Conda environment (uncomment if needed)
# source /home/kcrc915/miniconda3/etc/profile.d/conda.sh
# conda activate qiime2-2021.4

# ======================
# 2. SET PATHS (NO CHANGES NEEDED)
# ======================
METADATA="/home/kcrc915/BugSeqer/qiime2/metadata.tsv"
DIVERSITY_DIR="/home/kcrc915/BugSeqer/qiime2/second_analysis/core-metrics-results"
OUTPUT_DIR="/home/kcrc915/BugSeqer/qiime2/stat"

# Create output directories
mkdir -p ${OUTPUT_DIR}/script_output

# ======================
# 3. ALPHA DIVERSITY
# ======================
echo "Starting alpha diversity analyses..."

qiime diversity alpha-group-significance \
  --i-alpha-diversity ${DIVERSITY_DIR}/faith_pd_vector.qza \
  --m-metadata-file ${METADATA} \
  --o-visualization ${OUTPUT_DIR}/faiths_pd_statistics.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity ${DIVERSITY_DIR}/evenness_vector.qza \
  --m-metadata-file ${METADATA} \
  --o-visualization ${OUTPUT_DIR}/evenness_statistics.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity ${DIVERSITY_DIR}/shannon_vector.qza \
  --m-metadata-file ${METADATA} \
  --o-visualization ${OUTPUT_DIR}/shannon_pd_statistics.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity ${DIVERSITY_DIR}/observed_features_vector.qza \
  --m-metadata-file ${METADATA} \
  --o-visualization ${OUTPUT_DIR}/observed_features_pd_statistics.qzv

# ======================
# 4. BETA DIVERSITY (8 ANALYSES)
# ======================
echo "Starting beta diversity analyses..."

# Bray-Curtis (type and sub-type)
qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/bray_curtis_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column type \
  --o-visualization ${OUTPUT_DIR}/bray-curtis-type-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/bray_curtis_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column sub-type \
  --o-visualization ${OUTPUT_DIR}/bray-curtis-sub-type-significance.qzv \
  --p-pairwise

# Jaccard (type and sub-type)
qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/jaccard_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column type \
  --o-visualization ${OUTPUT_DIR}/jaccard-type-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/jaccard_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column sub-type \
  --o-visualization ${OUTPUT_DIR}/jaccard-sub-type-significance.qzv \
  --p-pairwise

# Unweighted UniFrac (type and sub-type)
qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column type \
  --o-visualization ${OUTPUT_DIR}/unweighted-unifrac-type-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column sub-type \
  --o-visualization ${OUTPUT_DIR}/unweighted-unifrac-sub-type-significance.qzv \
  --p-pairwise

# Weighted UniFrac (type and sub-type)
qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column type \
  --o-visualization ${OUTPUT_DIR}/weighted-unifrac-type-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix ${DIVERSITY_DIR}/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file ${METADATA} \
  --m-metadata-column sub-type \
  --o-visualization ${OUTPUT_DIR}/weighted-unifrac-sub-type-significance.qzv \
  --p-pairwise

echo "All 4 alpha and 8 beta diversity analyses completed successfully!"