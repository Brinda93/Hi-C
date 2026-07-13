#!/bin/bash -l
project_dir=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90_H3K27ac

job_dir="${project_dir}/JOBS/Convert_bdg_to_bw_after_MACS2"
mkdir -p "${job_dir}"

bdg_dir="${project_dir}/peaks_MACS2"

hg38_chrom_sizes=/gpfs/Labs/Dovat/HiC_NOV2025/IMR90/run_hic/data/hg38/hg38.chrom.sizes

samples=(PDL25 PDL33 PDL35 PDL44 PDL47 PDL48 PDL51 PDL52 PDL53)

for sample in "${samples[@]}"; do
        sample_bdg_dir="${bdg_dir}/${sample}"
        sample_bdg_path="${sample_bdg_dir}/${sample}_treat_pileup.bdg"
        sample_bdg_sorted_outpath="${sample_bdg_dir}/${sample}_treat_pileup.sorted.bdg"

        sample_bw_outpath="${sample_bdg_dir}/${sample}_treat_pileup.sorted.bw"

        job_file="${job_dir}/${sample}_bdg_to_bw.sh"
        log_file="${job_dir}/${sample}_bdg_to_bw.log"

cat <<EOF > "$job_file"
#!/bin/bash -l
#SBATCH --output=${log_file}
#SBATCH --error=${log_file}
#SBATCH -p compute
#SBATCH -c 4
#SBATCH --mem-per-cpu=16
#SBATCH -A lab_dovat

export PATH=/ri/shared/modules7/UCSCTools/406/bin/:$PATH

# sort the bdg file
sort -k1,1 -k2,2n "${sample_bdg_path}" > "${sample_bdg_sorted_outpath}"

# convert to bigWig file
bedGraphToBigWig "${sample_bdg_sorted_outpath}" "${hg38_chrom_sizes}" "${sample_bw_outpath}"

EOF
        echo "${job_file}"
        echo "${log_file}"

        sbatch "${job_file}"
done
