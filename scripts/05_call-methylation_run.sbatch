#!/bin/bash
#SBATCH --job-name=bismark_pe
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=7-00:00:00
#SBATCH --mem=64G

set -euo pipefail

########################## USAGE / ARGS ##########################
# Use it at your own risk
# Usage: sbatch 05_call-methylation_run.sbatch PREFIX R1.fastq.gz R2.fastq.gz /path/to/genome_folder [--non_directional|--pbat]
# Example:
#   sbatch 05_call-methylation_run.sbatch EN01 R1_trimmed.fastq.gz R2_trimmed_noG.fastq.gz /ref/hg38

if [ "$#" -lt 4 ]; then
  echo "Usage: sbatch $0 PREFIX R1.fastq(.gz) R2.fastq(.gz) GENOME_FOLDER [--non_directional|--pbat]"
  exit 1
fi

PREFIX="$1"
R1="$2"
R2="$3"
GENOME="$4"
LIBMODE="${5:-}"   # optional: --non_directional OR --pbat (leave empty for directional default)

if [[ ! -f "$R1" ]]; then echo "Error: R1 not found: $R1"; exit 1; fi
if [[ ! -f "$R2" ]]; then echo "Error: R2 not found: $R2"; exit 1; fi
if [[ ! -d "$GENOME" ]]; then echo "Error: GENOME folder not found: $GENOME"; exit 1; fi

########################## LOGGING ###############################
LOG_DIR="${PREFIX}_logs"
mkdir -p "$LOG_DIR"
exec > >(tee -i "$LOG_DIR/${PREFIX}.log") 2>&1

start_time=$(date +%s)
echo "== $(date) =="
echo "PREFIX      : $PREFIX"
echo "R1          : $R1"
echo "R2          : $R2"
echo "GENOME      : $GENOME"
echo "LIBMODE     : ${LIBMODE:-(directional default)}"
echo "CPUs (SLURM): ${SLURM_CPUS_PER_TASK:-1}"

########################## ENV ###################################
eval "$(conda shell.bash hook)"
conda activate methylation

echo "Bismark:  $(bismark --version | head -n1 || true)"
echo "Bowtie2:  $(bowtie2 --version | head -n1 || true)"
echo "Samtools: $(samtools --version | head -n1 || true)"

########################## DIRS ##################################
OUT="bismark_out_${PREFIX}"
TMP="bismark_tmp_${PREFIX}"
mkdir -p "$OUT" "$TMP"

########################## THREADS ###############################
# Use all CPUs for the underlying aligner; avoid --parallel unless needed (it multiplies RAM/CPU usage)
THREADS=${SLURM_CPUS_PER_TASK:-1}

########################## INDEX (one-time per genome) ###########
# Uncomment the next line the first time you run for a genome (or do it separately ahead of time):
# bismark_genome_preparation --bowtie2 --verbose "$GENOME"

########################## MAP ###################################
echo "== Mapping paired-end reads =="
bismark --bowtie2 \
  --genome "$GENOME" \
  -1 "$R1" -2 "$R2" \
  -p "$THREADS" \
  ${LIBMODE:+$LIBMODE} \
  --basename "$PREFIX" \
  --output_dir "$OUT" \
  --temp_dir "$TMP"

# Result: $OUT/${PREFIX}_pe.bam and a PE report

########################## DEDUP #################################
echo "== Deduplicating =="
deduplicate_bismark --paired "$OUT/${PREFIX}_pe.bam"
# Output: $OUT/${PREFIX}_pe.deduplicated.bam

########################## CALL METHYLATION ######################
echo "== Methylation extraction =="
bismark_methylation_extractor \
  --paired-end --comprehensive \
  --bedGraph --gzip \
  --multicore "$THREADS" \
  --buffer_size 8G \
  "$OUT/${PREFIX}_pe.deduplicated.bam"

########################## REPORTS ###############################
echo "== Reports =="
bismark2report
bismark2summary

########################## DONE ##################################
end_time=$(date +%s)
duration=$((end_time - start_time))
printf "== Finished: %s ==\n" "$(date)"
printf "Walltime: %02dh %02dm %02ds\n" $((duration/3600)) $(((duration%3600)/60)) $((duration%60))

printf "All completed, please check results at:\n"
printf "$OUT\n"
