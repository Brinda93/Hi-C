#!/bin/bash -l
set -euo pipefail

project_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac

job_dir="${project_dir}/JOBS/Scale_bedGraph"
mkdir -p "${job_dir}"

samples=(PDL25 PDL33 PDL35 PDL44 PDL47 PDL48 PDL51 PDL52 PDL53)
h3k27ac_samples=(PDL25_S3 PDL33_S17 PDL35_S24 PDL44_S38 PDL47_S45 PDL48_S52 PDL51_S59 PDL52_S66 PDL53_S73)
igg_samples=(PDL25_S7 PDL33_S21 PDL35_S28 PDL44_S42 PDL47_S49 PDL48_S56 PDL51_S63 PDL52_S70 PDL53_S77)

h3k27ac_bam_dir="${project_dir}/BOWTIE2_ALIGNED_BAM"
igg_bam_dir="${project_dir}/IgG_CTRL/BOWTIE2_ALIGNED_BAM"

h3k27ac_bedgraph_dir="${project_dir}/bedGraph_files"
igg_bedgraph_dir="${project_dir}/IgG_CTRL/bedGraph_files"

for i in "${!samples[@]}"; do

    sample="${samples[$i]}"
    h3k27ac_sample="${h3k27ac_samples[$i]}"
    igg_sample="${igg_samples[$i]}"

    h3k27ac_sample_bam="${h3k27ac_bam_dir}/${h3k27ac_sample}/${h3k27ac_sample}_H3K27ac.rmdup.bam"
    igg_sample_bam="${igg_bam_dir}/${igg_sample}/${igg_sample}_IgG.rmdup.bam"

    h3k27ac_bedgraph="${h3k27ac_bedgraph_dir}/${h3k27ac_sample}/${h3k27ac_sample}_H3K27ac.raw.bedgraph"
    igg_bedgraph="${igg_bedgraph_dir}/${igg_sample}/${igg_sample}_IgG.raw.bedgraph"

    scaled_h3k27ac_bedgraph="${h3k27ac_bedgraph_dir}/${h3k27ac_sample}/${h3k27ac_sample}_H3K27ac.SES_scaled.bedgraph"
    ses_sub_h3k27ac_bedgraph="${h3k27ac_bedgraph_dir}/${h3k27ac_sample}/${h3k27ac_sample}_H3K27ac.SES_subtracted.bedgraph"

    job_file="${job_dir}/${sample}_Scale_bedGraph.sh"
    log_file="${job_dir}/${sample}_Scale_bedGraph.log"

cat <<EOF > "$job_file"
#!/bin/bash -l
#SBATCH --output=${log_file}
#SBATCH --error=${log_file}
#SBATCH -p compute
#SBATCH -c 4
#SBATCH --mem-per-cpu=16
#SBATCH -A lab_dovat

set -euo pipefail

module load samtools
module load bedtools

# Input files
h3k27ac_sample_bam="${h3k27ac_sample_bam}"
igg_sample_bam="${igg_sample_bam}"
h3k27ac_bedgraph="${h3k27ac_bedgraph}"
igg_bedgraph="${igg_bedgraph}"

scaled_h3k27ac_bedgraph="${scaled_h3k27ac_bedgraph}"
ses_sub_h3k27ac_bedgraph="${ses_sub_h3k27ac_bedgraph}"

# Sanity checks
[[ -f "\$h3k27ac_sample_bam" ]] || { echo "Missing \$h3k27ac_sample_bam"; exit 1; }
[[ -f "\$igg_sample_bam" ]] || { echo "Missing \$igg_sample_bam"; exit 1; }
[[ -f "\$h3k27ac_bedgraph" ]] || { echo "Missing \$h3k27ac_bedgraph"; exit 1; }
[[ -f "\$igg_bedgraph" ]] || { echo "Missing \$igg_bedgraph"; exit 1; }

echo "Counting reads..."

h3k27ac_reads=\$(samtools view -c "\$h3k27ac_sample_bam")
igg_reads=\$(samtools view -c "\$igg_sample_bam")

if [[ "\$igg_reads" -eq 0 ]]; then
    echo "IgG read count is zero. Cannot compute scale."
    exit 1
fi

scale=\$(awk -v h="\$h3k27ac_reads" -v i="\$igg_reads" \
'BEGIN {printf "%.8f", i/h}')

echo "H3K27ac reads: \$h3k27ac_reads"
echo "IgG reads:     \$igg_reads"
echo "Scale factor:  \$scale"

echo "Scaling H3K27ac bedGraph..."

awk -v s="\$scale" 'BEGIN{OFS="\t"} { \$4 = \$4 * s; print }' \
"\$h3k27ac_bedgraph" > "\$scaled_h3k27ac_bedgraph"

echo "Performing background subtraction..."

bedtools unionbedg -i "\$scaled_h3k27ac_bedgraph" "\$igg_bedgraph" \
| awk 'BEGIN{OFS="\t"} { val=\$4-\$5; if(val<0) val=0; print \$1,\$2,\$3,val }' \
> "\$ses_sub_h3k27ac_bedgraph"

echo "Done."

EOF
        echo "${job_file}"
        echo "${log_file}"

        sbatch "$job_file"
done
