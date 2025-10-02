# Analysis of disulphite sequencing data with DMAP2

[DMAP2](https://github.com/jjovelc/Dayhoff_JovelJ_DMAP2.git) DMAP2 is a collection of Bash wrappers. The original “C code” you’re meant to have on the system lives in the sister repo [DMAP](https://github.com/peterstockwell/DMAP), which provides the compiled executables that DMAP2 calls (notably diffmeth and identgeneloc). The DMAP2 scripts then orchestrate trimming, mapping (via Bismark or BSMAPz), and the DMAP stats/annotation steps.

## Installation of DMAP

1. Cloine the github repo: 
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
  diffmeth

  #No sequence file information via -g or -G options
  #diffmeth v1.83: differential methylation analysis for RRBS & WGBS
  #Options:
  #   -r <posfile> read <posfile> as set of chr posit strand/meth (multiples allowed)
  #   -R <samorbamfile> read info from .sam/.bam file (multiples allowed)
  #   -s <posfile> as for -r, second group data
  #   -S <samorbamfile> as for -R, second group data
  #   -z/-Z switch between sam (-Z) & bam (-z) for -R/-S input - positional (def=-Z)
  #   -G <chr_info_file> file of chromosome IDs and filenames
  # or  -g <genomehead> dir and file string to locate genomic seq files by adding n.fa (obsolete, use -G method)
  #   -p <j,k> pairwise scan meth variance of RR frags j..k (Li, et al. (2010) PLOSBiology,11,e1000533)
  #   -P <j,k> pairwise scan force Fisher's exact frags j..k (Li, et al. (2010) PLOSBiology,11,e1000533)
  #   -x <j,k> do Chi Square if possible, else pairwise FE
  #   -X <j,k> as -x but force Chi Square for valid count fragments
  #   -q <j,k> as -x but choose lower Pr of Fisher's Exact, or Chi if valid
  #   -Q <j,k> as -q but show all paired FE Prs, or Chi if valid
  #   -a/-A/-B <j,k> ANOVA on %meth for groups; -A->show >meth group & sample counts; -B->more detail
  #   -e/-E <j,k> list each CpG for bins; -E=> only nonzero bins
  #   -D <j,k> derive mean & std deviation for valid bins
  #   -l/-L <j,k> list bins (-L=>only nonzero bins)
  #   -m treat complementary Cs of CpGs as separate (def=don't)
  #   -f <fold> require fold methylation difference (def=don't)
  #   -t <threshold> ignore CpGs with fewer than threshold counts (def=1)
  #   -T <hitthreshold> ignore bins with less than hitthreshold/CpG counts (def=0.0)
  #   -F <cntscrit> No. CpGs that must meet -t count criterion (def=all)
  #   -u <maxhitspercpg> ignore bins with more counts/CpG (def=0.0=ignore)
  #   -M <minmethprop> ignore bins with methylation below this (def=0.0=ignore)
  #   -U <prthreshold> ignore comparisons with Pr > prthreshold (def=don't=>-U 1.0)
  #   -k <maxchrno> allow upto maxchrno different chromosomes (def = ChrY, 24)
  #   -Y don't expect XY chromosomes, just numbers (def=do)
  #   -b <sambuflen> max read length for .sam files (def=150)
  #   -d display counts for each individual (def=don't)
  #   -c <n> restrict effort to Chromosome <n> (def = all chromosomes)
  #   -C <n> restrict bins to those with <n> or more CpGs
  #   -I <n> minimum of <n> individuals for a fragment (def=2)
  #   -j join adjacent RRBS fragments (def=don't)
  #   -K <clustersize> cluster bins to clustersize groups for quick lookup (def=1000)
  #   -H <Chdr> use Chdr as prefix for each chromosome (def=none)
  #   -N for 3' SAM/BAM RRBS reads map leading CpG to prev fragment (def=don't)
  #   -W <binwidth> make fixed width bins (def=rest. enz by size)
  #   -y <binfilename> read bin info from binfilename (chr start stop) (def=rest. enz)
  #   -n <restrictionfile> - use sites in <restrictionfile>, def=MspI
  #   -J include non-CpG methylation
  #   -o <outfile> - write output to <outfile> (def=stdout)  
```
