#!/bin/bash -l
#SBATCH --job-name=Run_FASTQC
#SBATCH --output=Run_FASTQC_output.%j.%N.txt
#SBATCH --error=Run_FASTQC_error.%j.%N.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=128G
#SBATCH --partition=compute


samples=(PDL25 PDL29 PDL33 PDL35 PDL40 PDL44 PDL47 PDL48 PDL51 PDL52 PDL53)
## ^^ you'll have to go back in and work on PDL51_1_3 again bc theres a weird naming mishap

fastq_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac/FASTQ

fastqc_output_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac/FASTQC/
mkdir -p "${fastqc_output_dir}"

module load fastqc
for sample in ${samples[@]}; do
        sample_fastq_dir="${fastq_dir}/${sample}"
        if [ -d "${sample_fastq_dir}" ]; then
                cd $sample_fastq_dir
                fastqc -o "${fastqc_output_dir}" *.fastq.gz
        fi
done
(base) [bxp5423@psh01com1hgtw00 SCRIPTS]$ 
