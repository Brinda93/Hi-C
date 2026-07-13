#!/bin/bash -l
set -euo pipefail

project_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac

job_dir="${project_dir}/JOBS/bigWig_deeptools"
mkdir -p "${job_dir}"

samples=(PDL25 PDL33 PDL35 PDL44 PDL47 PDL48 PDL51 PDL52 PDL53)
h3k27ac_samples=(PDL25_S3 PDL33_S17 PDL35_S24 PDL44_S38 PDL47_S45 PDL48_S52 PDL51_S59 PDL52_S66 PDL53_S73)
igg_samples=(PDL25_S7 PDL33_S21 PDL35_S28 PDL44_S42 PDL47_S49 PDL48_S56 PDL51_S63 PDL52_S70 PDL53_S77)

h3k27ac_bam_dir="${project_dir}/BOWTIE2_ALIGNED_BAM"
igg_bam_dir="${project_dir}/IgG_CTRL/BOWTIE2_ALIGNED_BAM"

for i in "${!samples[@]}"; do

    sample="${samples[$i]}"
    h3k27ac_sample="${h3k27ac_samples[$i]}"
    igg_sample="${igg_samples[$i]}"

    h3k27ac_sample_bam="${h3k27ac_bam_dir}/${h3k27ac_sample}/${h3k27ac_sample}_H3K27ac.rmdup.bam"
    igg_sample_bam="${igg_bam_dir}/${igg_sample}/${igg_sample}_IgG.rmdup.bam"

    ses_sub_h3k27ac_bigWig="${h3k27ac_bam_dir}/${h3k27ac_sample}/${h3k27ac_sample}_H3K27ac.SES_subtracted.bw"

    job_file="${job_dir}/${sample}_bigWig_deeptools.sh"
    log_file="${job_dir}/${sample}_bigWig_deeptools.log"

cat <<EOF > "$job_file"
#!/bin/bash -l
#SBATCH --output=${log_file}
#SBATCH --error=${log_file}
#SBATCH -p compute
#SBATCH -c 4
#SBATCH --mem-per-cpu=16
#SBATCH -A lab_dovat

module load samtools
module load deeptools

samtools index "${h3k27ac_sample_bam}"
samtools index "${igg_sample_bam}"

bamCompare \
        -b1 "${h3k27ac_sample_bam}" \
        -b2 "${igg_sample_bam}" \
        --operation subtract \
        --outFileName "${ses_sub_h3k27ac_bigWig}"

EOF
        echo "${job_file}"
        echo "${log_file}"

        sbatch "$job_file"
done
