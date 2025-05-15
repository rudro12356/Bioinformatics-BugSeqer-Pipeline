import pandas as pd
import random

# Read the sample IDs from the SRR_Acc_List.txt file
with open('SRR_Acc_List.txt', 'r') as file:
    sample_ids = [line.strip() for line in file.readlines()]

# Create a metadata DataFrame with 'sample-id' and 'type'
metadata = pd.DataFrame()

# Add 'sample-id' column from the list of sample IDs
metadata['sample-id'] = sample_ids

# Generate 'type' column (you can define your types here or randomly assign)
metadata['type'] = [random.choice(['TypeA', 'TypeB']) for _ in range(len(metadata))]

# Write the metadata to a new .tsv file
metadata.to_csv('metadata.tsv', sep='\t', index=False)

print("Metadata file created: metadata.tsv")

