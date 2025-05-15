# Set working directory to the place which has:
# 'metadata.tsv', 'table.qza', 'taxonomy.qza'
setwd("/home/kcrc915/BugSeqer/qiime2/qiime2_output")

# Load required libraries
# Install them if they are not available
#if (!requireNamespace("tidyverse", quietly = TRUE)) {
#    install.packages("tidyverse")
#}
#if (!requireNamespace("devtools", quietly = TRUE)) {
#    install.packages("devtools")
#}
#if (!requireNamespace("qiime2R", quietly = TRUE)) {
#    devtools::install_github("jbisanz/qiime2R", force = TRUE)
#}

library(tidyverse)
library(qiime2R)

# Check and insert '#q2:types' row if missing in metadata.tsv
metadata_path <- "metadata.tsv"
metadata_lines <- readLines(metadata_path)

if (!grepl("^#q2:types", metadata_lines[2])) {
    message("⚠️ Second row is missing '#q2:types'. Inserting default types...")

    # Backup the original file
    file.copy(metadata_path, paste0(metadata_path, ".bak"), overwrite = TRUE)

    # Insert a default type row (assuming the second column is Categorical)
    default_types <- paste0("#q2:types\tCategorical")
    metadata_lines <- append(metadata_lines, default_types, after = 1)
    writeLines(metadata_lines, metadata_path)
    message("✅ Inserted default '#q2:types' row and saved updated metadata.")
}

# Load input data
metadata <- read_q2metadata(metadata_path)
features_table <- read_qza("table.qza")$data
taxonomy_table <- read_qza("taxonomy.qza")$data %>% parse_taxonomy()

# Summarize taxonomy levels
taxasums_p <- summarize_taxa(features_table, taxonomy_table)$Phylum
taxasums_c <- summarize_taxa(features_table, taxonomy_table)$Class
taxasums_o <- summarize_taxa(features_table, taxonomy_table)$Order
taxasums_f <- summarize_taxa(features_table, taxonomy_table)$Family
taxasums_g <- summarize_taxa(features_table, taxonomy_table)$Genus
taxasums_s <- summarize_taxa(features_table, taxonomy_table)$Species

# Define a helper to plot and save heatmaps and barplots
save_plots <- function(taxa_data, level_name) {
    heatmap <- taxa_heatmap(taxa_data, metadata, "type")
    barplot <- taxa_barplot(taxa_data, metadata, "type")
    
    ggsave(paste0("heatmap_", tolower(level_name), ".pdf"), heatmap, height = 4, width = 8, device = "pdf")
    ggsave(paste0("barplot_", tolower(level_name), ".pdf"), barplot, height = 4, width = 8, device = "pdf")
}

# Generate and save plots for each level
save_plots(taxasums_p, "Phylum")
save_plots(taxasums_c, "Class")
save_plots(taxasums_o, "Order")
save_plots(taxasums_f, "Family")
save_plots(taxasums_g, "Genus")
save_plots(taxasums_s, "Species")
