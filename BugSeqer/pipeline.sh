#!/bin/bash
# Author: 16S rRNA sequencing team
# Description: Pipeline execution script
cd /home/kcrc915/BugSeqer/Raw_Reads

rm -rf raw_reads.zip raw_reads

bash get_fastq.sh

sleep 10

cd /home/kcrc915/BugSeqer/Pre-process/qc

bash fastq_gen.sh

sleep 30



cd /home/kcrc915/BugSeqer/qiime2

mkdir second_analysis

chmod 777 second_analysis

cd /home/kcrc915/BugSeqer/qiime2/second_analysis

mkdir script_output

chmod 777 script_output

cd /home/kcrc915/BugSeqer/qiime2/

python3 manifest_builder.py -i /home/kcrc915/BugSeqer/Raw_Reads/SRR_Acc_List.txt -p /home/kcrc915/BugSeqer/Raw_Reads/raw_reads

#sed -i '$d' manifest


sleep 10

#create metadata.tsv file manually and place it under qiime2 directory

cd /home/kcrc915/BugSeqer/qiime2/second_analysis

cp /home/kcrc915/BugSeqer/qiime2/manifest .

cp /home/kcrc915/BugSeqer/qiime2/metadata.tsv .

chmod 777 manifest

chmod 777 metadata.tsv

cd ../

source ~/miniconda3/etc/profile.d/conda.sh

conda activate qiime2-2021.4

# Submit the first job and capture the job ID
JOBID1=$(sbatch part1.slurm | awk '{print $4}')
echo "Submitted part1.slurm as Job ID $JOBID1"

# Print waiting message once
echo "Waiting for part1 (Job ID $JOBID1) to finish..."

# Wait silently until job completes
while squeue -j "$JOBID1" > /dev/null 2>&1; do
    sleep 15
done

echo "part1.slurm completed."


# Submit the first job and capture the job ID
JOBID1=$(sbatch part2.slurm | awk '{print $4}')
echo "Submitted part1.slurm as Job ID $JOBID1"

# Print waiting message once
echo "Waiting for part2 (Job ID $JOBID1) to finish..."

# Wait silently until job completes
while squeue -j "$JOBID1" > /dev/null 2>&1; do
    sleep 15
done

echo "part2.slurm completed."

# Submit the first job and capture the job ID
JOBID1=$(sbatch part3.slurm | awk '{print $4}')
echo "Submitted part3.slurm as Job ID $JOBID1"

# Print waiting message once
echo "Waiting for part3 (Job ID $JOBID1) to finish..."

# Wait silently until job completes
while squeue -j "$JOBID1" > /dev/null 2>&1; do
    sleep 15
done

echo "part3.slurm completed."



# Deactivate any active Conda env
conda deactivate

sleep 10

# Prepare output directory
cd /home/kcrc915/BugSeqer/qiime2
rm -rf qiime2_output
mkdir qiime2_output
chmod 777 qiime2_output

# Copy required files
cd qiime2_output
cp /home/kcrc915/BugSeqer/R/Heatmap-barplot.R .
cp /home/kcrc915/BugSeqer/qiime2/second_analysis/metadata.tsv .
cp /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/table.qza .
cp /home/kcrc915/BugSeqer/qiime2/second_analysis/artifacts/taxonomy.qza .

# Run the R script automatically (non-interactive)
Rscript Heatmap-barplot.R


cd /home/kcrc915/BugSeqer/qiime2/

rm -rf lefse

mkdir lefse

chmod 777 lefse

cd lefse

cp /home/kcrc915/BugSeqer/LEfSe/format_rel_level.sh .

cp /home/kcrc915/BugSeqer/LEfSe/rel_format.py .

source ~/miniconda3/etc/profile.d/conda.sh

conda activate lefse_env

bash format_rel_level.sh

source ~/miniconda3/etc/profile.d/conda.sh


conda deactivate


cd /home/kcrc915/BugSeqer/qiime2

rm -rf stat

mkdir stat

chmod 777 stat

cd stat

mkdir script_output

chmod 777 script_output

cd /home/kcrc915/BugSeqer/qiime2/stat

cp /home/kcrc915/BugSeqer/Stat/stat_alpha.slurm .

source ~/miniconda3/etc/profile.d/conda.sh

conda activate qiime2-2021.4

sbatch stat_alpha.slurm


sleep 10


cd /home/kcrc915/BugSeqer/qiime2

rm -rf ancom

mkdir ancom

chmod 777 ancom

cd ancom

mkdir script_output

chmod 777 script_output

cd /home/kcrc915/BugSeqer/qiime2/ancom

cp /home/kcrc915/BugSeqer/ANCOM/ancom.sh .

chmod 777 ancom.sh

bash ancom.sh


sleep 200

cd /home/kcrc915/BugSeqer/

bash ancom_pdf.sh

bash stat_pdf.sh


echo("16s rRNA Pipeline completed")
















