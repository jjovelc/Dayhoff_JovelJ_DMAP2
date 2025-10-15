#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=7-00:00:00
#SBATCH --mem=8G

####### Handle user-defined prefix #########################

# Ensure the user provides a prefix
if [ -z "$1" ]; then
  echo "Usage: $0 PREFIX"
  exit 1
fi

PREFIX=$1
LOG_DIR="${PREFIX}_log-err_files"
mkdir -p "$LOG_DIR"

# Redirect output and error logs
#SBATCH --output=%x.out
#SBATCH --error=%x.err

exec > "$LOG_DIR/${PREFIX}.log"
exec 2> "$LOG_DIR/${PREFIX}.err"

####### Set environment variables ###############

start_time=$(date +%s)
echo "Job started on: $(date)"

####### Run your script #########################
eval "$(conda shell.bash hook)"
conda activate methylation

R1="$2"
R2="$3"

# Strip path and any fastq extension (case-insensitive, handles .gz)
BASE1="$(basename "$R1" | sed -E 's/\.(fastq|fq|FASTQ|FQ)(\.gz)?$//')"
BASE2="$(basename "$R2" | sed -E 's/\.(fastq|fq|FASTQ|FQ)(\.gz)?$//')"

OUT1="${BASE1}_trimmed.fastq"
OUT2="${BASE2}_trimmed.fastq"


cutadapt -a TGGAATTCTCGGGTGCCAAGG -A GATCGTCGGACTGTAGAACTCTGAAC -q 30 --nextseq-trim=20 --overlap 3 --error-rate 0.2 --minimum-length 50 --pair-filter=any -o "$OUT1" -p "$OUT2" "$R1" "$R2"


end_time=$(date +%s)
echo "Job ended on: $(date)"

# Calculate the difference in times to get the duration
duration=$((end_time - start_time))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "Job duration: $hours hours, $minutes minutes, $seconds seconds"
