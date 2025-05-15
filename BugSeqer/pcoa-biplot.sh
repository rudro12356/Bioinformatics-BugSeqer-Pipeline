#!/bin/bash

module load qiime2/2022.2

cd /work/biocore/zalsafwani/CRC_data/raw_reads/qiime2/second_analysis/pcoa

# Make the relative frequency table from the rarefied table
qiime feature-table relative-frequency \
--i-table ../core-metrics-results/rarefied_table.qza \
--o-relative-frequency-table rarefied_table_relative.qza

# Make the biplot for unweighted UniFrac
qiime diversity pcoa-biplot \
--i-pcoa ../core-metrics-results/unweighted_unifrac_pcoa_results.qza \
--i-features rarefied_table_relative.qza \
--o-biplot biplot_matrix_unweighted_unifrac.qza


# Turn this matrix into an emperor plot
qiime emperor biplot \
--i-biplot biplot_matrix_unweighted_unifrac.qza \
--m-sample-metadata-file ../metadata.tsv \
--o-visualization unweighted_unifrac_emperor_biplot.qzv
