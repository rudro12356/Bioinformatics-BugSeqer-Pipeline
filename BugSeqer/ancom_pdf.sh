#!/bin/bash

INPUT_DIR="/home/kcrc915/BugSeqer/qiime2/ancom"
OUTPUT_DIR="${INPUT_DIR}/extracted_html"

# Check if the output directory exists, create if it doesn't
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo "📂 Created output directory: $OUTPUT_DIR"
fi

for qzv_file in "$INPUT_DIR"/*.qzv; do
    base=$(basename "$qzv_file" .qzv)
    extract_dir="${OUTPUT_DIR}/${base}_unzipped"

    # Unzip the .qzv file to the output directory
    unzip -o "$qzv_file" -d "$extract_dir" > /dev/null 2>&1

    if [ -f "$extract_dir"/*/data/index.html ]; then
        echo "✅ Extracted: $base.qzv → $extract_dir"
    else
        echo "⚠️ Extracted: $base.qzv but no index.html found"
    fi
done

echo "📂 All .qzv files extracted to: $OUTPUT_DIR"

