# denim
A pipeline for assembling DE-Novo ITS from Metagenomes.

Usage: `denim.sh -f FORWARD_READS -r REVERSE_READS -d DATABASE_DIRECTORY -o OUTPUT_DIRECTORY (-t THREADS -n N_READS -w WORKING_DIRECTORY)`

Help: `denim.sh -h`

# Installation
Download the denim files.

```bash
git clone https://github.com/tage-ro/denim.git
cd denim
```

Denim relies on fastp, BBmap, SPAdes and ITSx. Install them in a conda virtual environment by running:

```bash
conda env create -n denim --file denim_env.yml
```

You also need an ITS database to map reads to, in FASTA format. I suggest the <a class="reference external" href="https://unite.ut.ee/repository.php" target="_blank" rel="noopener noreferrer">UNITE database</a>.

You will probably want to use the current one for all eukaryotes. Use of the "dev" fasta may result in more complete ITS sequence assembly, as it contains flanking sequences.

Now you have everything you need to run denim. For further instructions:

```bash
conda activate denim
bash denim.sh -h

```

For convenience, you may want to copy denim.sh to the bin-directory of your conda environment, allowing you to run it from anywhere.

```bash
cp denim.sh /path/to/your/conda/env/denim/bin
denim.sh -h
```

# Troubleshooting
Denim is developed for use on Linux systems on high performance computing clusters. If you run denim on your personal computer, consider drastically reducing the number of reads processed (`-n`).
