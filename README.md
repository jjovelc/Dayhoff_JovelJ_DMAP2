# Analysis of disulphite sequencing data with DMAP2

[DMAP2](https://github.com/jjovelc/Dayhoff_JovelJ_DMAP2.git) DMAP2 is a collection of Bash wrappers. The original “C code” you’re meant to have on the system lives in the sister repo [DMAP](https://github.com/peterstockwell/DMAP), which provides the compiled executables that DMAP2 calls (notably diffmeth and identgeneloc). The DMAP2 scripts then orchestrate trimming, mapping (via Bismark or BSMAPz), and the DMAP stats/annotation steps.

## Installation of DMAP

1. Clone the github repo: 
```bash
  git clone git@github.com:jjovelc/Dayhoff_JovelJ_DMAP2.git
  cd DMAP/src/
  make
```

2. Create a conda environment to install other pieces of software required by the pipeline:
```bash
  mamba create -n methylation python=3.9
  conda activate methylation

  # Make DMAP available inside the conda env
  ##########################################
  # Replace this with YOUR actual DMAP path
  DMAP_PATH="/home/juan.jovel/software/DMAP/src"

  # Create the activation directory if it doesn't exist
  mkdir -p $CONDA_PREFIX/etc/conda/activate.d

  # Create the script that adds DMAP to PATH
  echo "export PATH=\"${DMAP_PATH}:\$PATH\"" > $CONDA_PREFIX/etc/conda/activate.d/add_dmap.sh

  # Make it executable
  chmod +x $CONDA_PREFIX/etc/conda/activate.d/add_dmap.sh

  # Verify the script was created
  cat $CONDA_PREFIX/etc/conda/activate.d/add_dmap.sh

  # Veryfy that DMAP is functional inside the conda env methylation
  diffmeth # Help of software should be displayed
```

3. Install additional software required (inside the methylation env):
```bash
  mamba install bioconda::bowtie2 -y
  mamba install bioconda::samtools -y
  mamba install bioconda::bismark -y
  mamba install bioconda::fastqc -y
```

4. Install bsmapz (from source code)
```bash
  mamba create -n bsmapz-src -c conda-forge -c bioconda \
  make gcc gxx zlib samtools -y
  conda activate bsmapz-src

  git clone https://github.com/zyndagj/BSMAPz.git
  cd BSMAPz
  make bsmapz             # produces ./bsmapz
  ./bsmapz -h

  # make it globally reachable
  mkdir -p ~/local/bin
  cp ./bsmapz ~/local/bin/
  echo 'export PATH="$HOME/local/bin:$PATH"' >> ~/.bashrc
  hash -r
```

5. Prepare genome (Homo sapiens in this case).
```bash
  # The genome used here was UCSC hg38, which can be dowloaded with the following command:
  # wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
  # And the corresponding GTF (annotation) file:
  # wget wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.knownGene.gtf.gz
  # gunzip hg38.fa.gz hg38.knownGene.gtf.gz

  # Run bismark_genome_preparation which was installed as described in numeral 3.
  
  sbatch 01_genome_prep.sbatch <PREFIX>

```



Paper describing [Bismark](https://academic.oup.com/bioinformatics/article/27/11/1571/216956?login=true) 
