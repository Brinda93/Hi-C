#!/bin/bash -l

project_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac
fastq_dir="${project_dir}/FASTQ"
output_path="${project_dir}/BOWTIE2_ALIGNED_BAM"
mkdir -p "${output_path}"

job_dir="${project_dir}/JOBS/BOWTIE2_ALIGNED_BAM"
mkdir -p "${job_dir}"

hg38_cutntag_ref="${project_dir}/hg38_cutntag/hg38_cutntag"
#chrom_sizes="${bwa_index}/hg38.chrom.sizes"

#samples=(PDL25_S3 PDL29_S10 PDL33_S17 PDL35_S24 PDL40_S31 PDL44_S38 PDL47_S45 PDL48_S52 PDL51_S59 PDL52_S66 PDL53_S73)
samples=(PDL52_S66)

for sample in "${samples[@]}"; do
        sample_R1_fastq="${fastq_dir}/${sample}/${sample}_R1.fastq.gz"
        sample_R2_fastq="${fastq_dir}/${sample}/${sample}_R2.fastq.gz"

        sample_output_dir="${output_path}/${sample}"
        mkdir -p "${sample_output_dir}"

        sample_sorted_output_path="${sample_output_dir}/${sample}_H3K27ac.sorted.bam"

        job_file="${job_dir}/${sample}_H3K27ac_BAM_bowtie2_align.sh"
        log_file="${job_dir}/${sample}_H3K27ac_BAM_bowtie2_align.log"

cat <<EOF> "$job_file"
#!/bin/bash -l
#SBATCH --output=$log_file
#SBATCH --error=$log_file
#SBATCH -p compute
#SBATCH -c 4
#SBATCH --mem-per-cpu=16
#SBATCH -A lab_dovat

module load bowtie2
module load samtools

bowtie2 -x "${hg38_cutntag_ref}" \
        -1 "${sample_R1_fastq}" \
        -2 "${sample_R2_fastq}" \
        --very-sensitive \
        -X 2000 \
        -p 16 \
        | samtools sort -@ 16 -o "${sample_sorted_output_path}"

samtools index "${sample_sorted_output_path}"

EOF
        echo "${job_file}"
        echo "${log_file}"

        sbatch "${job_file}"
done
