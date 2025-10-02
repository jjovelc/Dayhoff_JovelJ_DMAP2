# Analysis of disulphite sequencing data with DMAP2

[DMAP2](https://github.com/jjovelc/Dayhoff_JovelJ_DMAP2.git) DMAP2 is a collection of Bash wrappers. The original “C code” you’re meant to have on the system lives in the sister repo [DMAP](https://github.com/peterstockwell/DMAP), which provides the compiled executables that DMAP2 calls (notably diffmeth and identgeneloc). The DMAP2 scripts then orchestrate trimming, mapping (via Bismark or BSMAPz), and the DMAP stats/annotation steps.

## Installation of DMAP

1. Cloine the github repo: 
```bash
  git clone https://github.com/peterstockwell/DMAP
  cd DMAP/src/
  make
```


