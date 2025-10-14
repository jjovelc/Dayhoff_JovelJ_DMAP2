cutadapt \
  -a TGGAATTCTCGGGTGCCAAGG -A GATCGTCGGACTGTAGAACTCTGAAC \
  -q 30 \                       # trim 3′ ends to Q30 on both reads
  --nextseq-trim=20 \           # keep this for poly-G artifacts
  --overlap 3 --error-rate 0.2 \
  --minimum-length 15 --pair-filter=any \
  -o SRR18283145_trimmed_R1.fastq -p SRR18283145_trimmed_R2.fastq \
  SRR18283145_1.fastq SRR18283145_2.fastq
