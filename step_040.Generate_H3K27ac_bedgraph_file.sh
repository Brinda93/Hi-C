#!/bin/bash -l

project_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac
bowtie_bam_dir="${project_dir}/BOWTIE2_ALIGNED_BAM"

job_dir="${project_dir}/JOBS/Generate_bedGraph"
mkdir -p "${job_dir}"

#samples=(PDL25_S3 PDL29_S10 PDL33_S17 PDL35_S24 PDL40_S31 PDL44_S38 PDL47_S45 PDL48_S52 PDL51_S59 PDL53_S73)
samples=(PDL52_S66)

for sample in "${samples[@]}"; do
        bam_rmdup_path="${bowtie_bam_dir}/${sample}/${sample}_H3K27ac.rmdup.bam"

        bedgraph_output_dir="${project_dir}/bedGraph_files/${sample}"
        mkdir -p "${bedgraph_output_dir}"

        bedgraph_file_sample_path="${bedgraph_output_dir}/${sample}_H3K27ac.raw.bedgraph"

        job_file="${job_dir}/${sample}_H3K27ac_Make_bedGraph.sh"
        log_file="${job_dir}/${sample}_H3K27ac_Make_bedGrah.log"

cat <<EOF> "$job_file"
#!/bin/bash -l
#SBATCH --output=$log_file
#SBATCH --error=$log_file
#SBATCH -p compute
#SBATCH -c 4
#SBATCH --mem-per-cpu=16
#SBATCH -A lab_dovat

module load bedtools
bedtools genomecov \
        -ibam "${bam_rmdup_path}" \
        -bg \
        > "${bedgraph_file_sample_path}"

EOF
        echo "${job_file}"
        echo "${log_file}"

        sbatch "${job_file}"
done
