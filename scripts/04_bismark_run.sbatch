#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=7-00:00:00
#SBATCH --mem=64G

####### Handle user-defined prefix #########################

# Ensure the user provides required arguments
if [ "$#" -lt 3 ]; then
  echo "Usage: sbatch $0 PREFIX R1.fastq R2.fastq"
  echo "Example: sbatch $0 sample1 reads_R1_trimmed.fastq reads_R2_trimmed.fastq"
  exit 1
fi

PREFIX="$1"
R1="$2"
R2="$3"

# Validate input files exist
if [[ ! -f "$R1" ]]; then
  echo "Error: R1 file not found: $R1"
  exit 1
fi

if [[ ! -f "$R2" ]]; then
  echo "Error: R2 file not found: $R2"
  exit 1
fi

# Create log directory
LOG_DIR="${PREFIX}_log-err_files"
mkdir -p "$LOG_DIR"

# Redirect output and error logs
exec > "$LOG_DIR/${PREFIX}.log" 2>&1

####### Set environment variables ###############

start_time=$(date +%s)
echo "Job started on: $(date)"
echo "Prefix: $PREFIX"
echo "R1: $R1"
echo "R2: $R2"
echo "CPUs allocated: $SLURM_CPUS_PER_TASK"

####### Activate conda environment #########################

eval "$(conda shell.bash hook)"
conda activate methylation

####### Set paths and extract sample name #########################

# Corrected Bismark genome path
GENOME="/work/vetmed_data/jj/projects/dh/DMAP2"

# Extract sample name from already-trimmed files
# Input example: SRR18283145_1_trimmed.fastq or SRR18283145_R1_trimmed.fastq
BASE_R1=$(basename "$R1")

# Remove: _1_trimmed, _2_trimmed, _R1_trimmed, _R2_trimmed, and any file extension
SAMPLE=$(echo "$BASE_R1" | sed -E 's/[_\.](1|2|R1|R2)_trimmed\.(fastq|fq)(\.gz)?$//' | sed -E 's/[_\.](1|2|R1|R2)\.(fastq|fq)(\.gz)?$//')

echo "Sample name: $SAMPLE"
echo "Input R1: $BASE_R1"
echo "Input R2: $(basename "$R2")"

# Create output directories
OUT="bismark_out"
TMP="bismark_tmp"
mkdir -p "$OUT" "$TMP"

####### Run Bismark #########################

echo "Running Bismark with:"
echo "  Genome: $GENOME"
echo "  Sample: $SAMPLE"
echo "  Threads: 4 per instance, 2 parallel instances"

bismark --bowtie2 \
  --genome "$GENOME" \
  -1 "$R1" \
  -2 "$R2" \
  -p 4 \
  --parallel 2 \
  --basename "$SAMPLE" \
  --output_dir "$OUT" \
  --temp_dir "$TMP"

BISMARK_EXIT=$?

if [ $BISMARK_EXIT -eq 0 ]; then
  echo "Bismark completed successfully"
  echo "Output files in: $OUT/"
  ls -lh "$OUT/"
else
  echo "ERROR: Bismark failed with exit code $BISMARK_EXIT"
fi

####### Calculate job duration #########################

end_time=$(date +%s)
echo "Job ended on: $(date)"

duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "Job duration: ${hours}h ${minutes}m ${seconds}s"

exit $BISMARK_EXIT
