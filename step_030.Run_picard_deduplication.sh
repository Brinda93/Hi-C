#!/bin/bash -l

project_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac
bowtie_bam_dir="${project_dir}/BOWTIE2_ALIGNED_BAM"

picard_jar="/ri/shared/modules7/picard/2.26.10/bin/picard.jar"

job_dir="${project_dir}/JOBS/PICARD_DEDUPLICATION"
mkdir -p "${job_dir}"

#samples=(PDL25_S3 PDL29_S10 PDL33_S17 PDL35_S24 PDL40_S31 PDL44_S38 PDL47_S45 PDL48_S52 PDL51_S59 PDL52_S66 PDL53_S73)
samples=(PDL52_S66)

for sample in "${samples[@]}"; do
        sample_bam_path="${bowtie_bam_dir}/${sample}/${sample}_H3K27ac.sorted.bam"
        bam_rmdup_path="${bowtie_bam_dir}/${sample}/${sample}_H3K27ac.rmdup.bam"

        sample_metrics_file="${bowtie_bam_dir}/${sample}/${sample}_H3K27ac_rmdup_METRICS.txt"

        job_file="${job_dir}/${sample}_H3K27ac_BAM_picard_dedup.sh"
        log_file="${job_dir}/${sample}_H3K27ac_BAM_picard_dedup.log"

cat <<EOF> "$job_file"
#!/bin/bash -l
#SBATCH --output=$log_file
#SBATCH --error=$log_file
#SBATCH -p compute
#SBATCH -c 4
#SBATCH --mem-per-cpu=16
#SBATCH -A lab_dovat

module load java

java -jar "${picard_jar}" MarkDuplicates \
        -I "${sample_bam_path}" \
        -O "${bam_rmdup_path}" \
        -M "${sample_metrics_file}" \
        -REMOVE_DUPLICATES true

EOF
        echo "${job_file}"
        echo "${log_file}"

        sbatch "${job_file}"
done
(base) [bxp5423@psh01com1hgtw00 SCRIPTS]$ 
