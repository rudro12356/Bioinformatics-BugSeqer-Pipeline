#!/bin/bash

module load qiime2/2021.4

qiime srs SRS   \
    --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/table.qza   \
    --p-c-min 96040   \
    --o-normalized-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/norm-table.qza   \
    --verbose
    
qiime feature-table summarize \
    --i-table /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/norm-table.qza \
    --o-visualization /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/norm-table.qzv
