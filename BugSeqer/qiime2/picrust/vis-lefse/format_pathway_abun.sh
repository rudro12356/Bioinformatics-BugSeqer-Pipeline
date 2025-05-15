#!/bin/bash

# 1. Verify PICRUSt2 output exists
PICRUST_OUT="/home/kcrc915/BugSeqer/qiime2/picrust/output/pathways_out/path_abun_unstrat.tsv"
if [ ! -f "$PICRUST_OUT" ]; then
    echo "ERROR: PICRUSt2 output not found at $PICRUST_OUT"
    echo "Run PICRUSt2 analysis first"
    exit 1
fi

# 2. Copy the file (no unzip needed)
cp "$PICRUST_OUT" .

# 3. Prepare metadata - verify column 11 exists first
METADATA="/home/kcrc915/BugSeqer/qiime2/metadata.tsv"
if [ $(awk -F'\t' 'NR==1{print NF}' "$METADATA") -lt 11 ]; then
    echo "ERROR: Metadata doesn't have 11 columns"
    exit 1
fi

# Create sample list with simplified group names
cut -f 1,11 "$METADATA" | \
    sed 's/Healthy volunteer/Healthy/g; s/UK control/Control/g' > sample_list_type.tsv

# 4. Format for LEfSe (using fixed pathway_format.py)
python pathway_format.py \
  -i sample_list_type.tsv \
  -r path_abun_unstrat.tsv \
  -o path_abun_modified.tsv

# 5. Install missing dependencies if needed
if ! python -c "import rpy2" 2>/dev/null; then
    echo "Installing rpy2..."
    pip install rpy2
fi

# 6. Run LEfSe analysis
lefse-format_input.py \
  path_abun_modified.tsv \
  path_abun_modified.in \
  -c 1 -u 2 -o 1000000

run_lefse.py path_abun_modified.in path_abun_modified.res

# 7. Generate plot
lefse-plot_res.py \
  path_abun_modified.res \
  pathway_abundance.png \
  --title "Pathway Abundance (Healthy vs CRC)" \
  --dpi 300