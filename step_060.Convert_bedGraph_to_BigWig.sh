#!/bin/bash -l

project_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac
bedgraph_dir="${project_dir}/bedGraph_files"

job_dir="${project_dir}/JOBS/Generate_bigWig"
mkdir -p "${job_dir}"

hg38_chrom_sizes=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90/run_hic/data/hg38/hg38.chrom.sizes

bigwig_dir="${project_dir}/bigWig_files"
mkdir -p "${bigwig_dir}"

samples=(PDL25_S3 PDL29_S10 PDL33_S17 PDL35_S24 PDL40_S31 PDL44_S38 PDL47_S45 PDL48_S52 PDL51_S59 PDL52_S66 PDL53_S73)

for sample in "${samples[@]}"; do
        ses_subtracted_bedgraph="${bedgraph_dir}/${sample}/${sample}_H3K27ac.SES_subtracted.bedgraph"
        ses_subtracted_sorted_output="${bedgraph_dir}/${sample}/${sample}_H3K27ac.SES_subtracted.sorted.bedgraph"
        ses_subtracted_bigwig_dir="${bedgraph_dir}/${sample}"
        mkdir -p "${ses_subtracted_bigwig_dir}"

        ses_subtracted_bigwig="${ses_subtracted_bigwig_dir}/${sample}_H3K27ac.SES_subtracted.bw"

        job_file="${job_dir}/${sample}_generate_bigWig.sh"
        log_file="${job_dir}/${sample}_generate_bigWig.log"

cat <<EOF> "$job_file"
#!/bin/bash -l
#SBATCH --output=$log_file
#SBATCH --error=$log_file
#SBATCH -p compute
#SBATCH -c 4
#SBATCH --mem-per-cpu=16
#SBATCH -A lab_dovat

# sort the SES-subtracted .bedgraph file
sort -k1,1 -k2,2n "${ses_subtracted_bedgraph}" > "${ses_subtracted_sorted_output}"

# convert to BigWig file
module load ucsc-tools
bedGraphToBigWig "${ses_subtracted_sorted_output}" "${hg38_chrom_sizes}" "${ses_subtracted_bigwig}"

EOF
        echo "${job_file}"
        echo "${log_file}"

        sbatch "${job_file}"
done
