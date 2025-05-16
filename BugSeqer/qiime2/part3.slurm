#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=12:00:00
#SBATCH --job-name=analysis_part3
#SBATCH --partition=debug
#SBATCH --error=/home/kcrc915/BugSeqer/qiime2/second_analysis/script_output/err_%j.out
#SBATCH --output=/home/kcrc915/BugSeqer/qiime2/second_analysis/script_output/std_%j.out
#SBATCH --open-mode=append


#module load qiime2/2021.4

cd /home/kcrc915/BugSeqer/qiime2/second_analysis

############################################
# Declare important local variables
############################################

# For diversity core-metrics-phylogenetic, the value was determined from 
# the visulization for the feature table in order to exclude as few samples as possible
p_sampling_depth=37910



qiime diversity core-metrics-phylogenetic \
    --i-phylogeny /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/rooted-tree.qza \
    --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/table.qza \
    --p-sampling-depth $p_sampling_depth \
    --m-metadata-file /home/kcrc915/BugSeqer/qiime2/second_analysis/metadata.tsv \
    --output-dir /home/kcrc915/BugSeqer/qiime2/second_analysis/core-metrics-results


# pcoa plots
echo "Started bray-curtis-pcoa-matrix.qza at: $(date)" 

qiime diversity pcoa \
        --i-distance-matrix /home/kcrc915/BugSeqer/qiime2/second_analysis/core-metrics-results/bray_curtis_distance_matrix.qza \
        --p-number-of-dimensions 2 \
        --o-pcoa /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/bray-curtis-pcoa-matrix.qza
		
echo "Finished at: $(date)"

echo "Started unweighted-unifrac-pcoa-matrix.qza at: $(date)" 

qiime diversity pcoa \
        --i-distance-matrix /home/kcrc915/BugSeqer/qiime2/second_analysis/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
        --p-number-of-dimensions 2 \
        --o-pcoa /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/unweighted-unifrac-pcoa-matrix.qza
echo "Finished at: $(date)"

echo "Started weighted-unifrac-pcoa-matrix.qza at: $(date)" 

qiime diversity pcoa \
        --i-distance-matrix /home/kcrc915/BugSeqer/qiime2/second_analysis/core-metrics-results/weighted_unifrac_distance_matrix.qza \
        --p-number-of-dimensions 2 \
        --o-pcoa /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/weighted-unifrac-pcoa-matrix.qza
echo "Finished at: $(date)"
		
echo "Started jaccard-pcoa-matrix.qza at: $(date)" 

qiime diversity pcoa \
        --i-distance-matrix /home/kcrc915/BugSeqer/qiime2/second_analysis/core-metrics-results/jaccard_distance_matrix.qza \
        --p-number-of-dimensions 2 \
        --o-pcoa /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/jaccard-pcoa-matrix.qza
echo "Finished at: $(date)"


# Export only files that are less than 100M
for file in artifacts/*; do
    output_path=$(echo $file | sed -E 's#^.*/(.*)\.qz[av]$#exports/\1#')
	size=$(du -s $file | sed -E 's#^(.*)\s.*$#\1#')
	if [[ !( -e $output_path )  &&  $( echo "$size<100000" | bc  -l ) == 1 ]]
        then
                qiime tools export \
                        --input-path $file \
                        --output-path $output_path
        fi
done

for file in core-metrics-results/*; do
    output_path=$(echo $file | sed -E 's#^.*/(.*)\.qz[av]$#exports/\1#')
    size=$(du -s $file | sed -E 's#^(.*)\s.*$#\1#')
    if [[ !( -e $output_path )  &&  $( echo "$size<100000" | bc  -l ) == 1 ]]
        then
                qiime tools export \
                        --input-path $file \
                        --output-path $output_path
        fi
done

# Copy taxonomy to feature table dir
cp /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/taxonomy/taxonomy.tsv /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table

# Modify header
sed -i '1d' /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/taxonomy.tsv
sed -i '1i #OTUID\ttaxonomy\tconfidence' /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/taxonomy.tsv

biom add-metadata \
    -i /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table.biom \
    -o /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table-w-taxa.biom \
    --observation-metadata-fp /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/taxonomy.tsv \
    --sc-separated taxonomy

biom convert \
    -i /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table-w-taxa.biom \
    -o /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table-w-taxa.tsv \
    --to-tsv \
    --header-key 'taxonomy' \
    --output-metadata-id 'Consensus Lineage'
# Convert feature table from biom to tsv and add in taxonomy data along the way
# This whole biom thing is kind of confusing, but basically all that is 
# happening here is OTU IDs are being mapped to taxonomic identifiers
 
# Copy taxonomy to feature table dir
cp /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/taxonomy/taxonomy.tsv /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table

# Modify header
sed -i '1d' /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/taxonomy.tsv
sed -i '1i #OTUID\ttaxonomy\tconfidence' /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/taxonomy.tsv

biom add-metadata \
    -i /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table.biom \
    -o /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table-w-taxa.biom \
    --observation-metadata-fp /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/taxonomy.tsv \
    --sc-separated taxonomy

biom convert \
    -i /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table-w-taxa.biom \
    -o /home/kcrc915/BugSeqer/qiime2/second_analysis/exports/table/feature-table-w-taxa.tsv \
    --to-tsv \
    --header-key 'taxonomy' \
    --output-metadata-id 'Consensus Lineage'

# Get nice relative abundance data for levels 6 and 2

declare -a taxa_levels=("2" "3" "4" "5" "6" "7")
qza=".qza"

for taxa_level in "${taxa_levels[@]}"; do
    out_collapsed_path="/home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/phyla_table_level_$taxa_level$qza"
    out_rel_path="/home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/phyla_table_rel_level_$taxa_level$qza"
    
    qiime taxa collapse \
        --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/table.qza \
        --i-taxonomy /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxonomy.qza \
        --p-level $taxa_level \
        --o-collapsed-table $out_collapsed_path

    qiime feature-table relative-frequency \
        --i-table $out_collapsed_path \
        --o-relative-frequency-table $out_rel_path
    
    for file in artifacts/*; do
        output_path=$(echo $file | sed -E 's#^.*/(.*)\.qz[av]$#exports/\1#')
        size=$(du -s $file | sed -E 's#^(.*)\s.*$#\1#')
        if [[ !( -e $output_path )  &&  $( echo "$size<100000" | bc  -l ) == 1 ]]
            then
                    qiime tools export \
                            --input-path $file \
                            --output-path $output_path
            fi
    done
    
    biom_path="/home/kcrc915/BugSeqer/qiime2/second_analysis/exports/phyla_table_rel_level_$taxa_level/feature-table.biom"
    tsv_path="/home/kcrc915/BugSeqer/qiime2/second_analysis/exports/phyla_table_rel_level_$taxa_level/phyla_table_rel_level_$taxa_level.tsv"
    biom convert \
        -i $biom_path \
        -o $tsv_path \
        --to-tsv 
done


