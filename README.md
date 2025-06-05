# denim
A pipeline for assembling DE-Novo Internally transcribed spacers from Metagenomes.

Usage: `Usage: denim.sh -f FORWARD_READS -r REVERSE_READS -d DATABASE_FILE [-o OUTPUT_DIRECTORY -t THREADS -n N_READS -w WORKING_DIRECTORY -c]`

Help: `denim.sh -h`
# What does denim do?
Denim is a simple pipeline. It does quality control of reads, followed by mapping reads to an ITS sequence database, followed by assembly of mapped reads, followed by identification of ITS sequences in assembled contigs. It tries to do all of this as quickly as possible.

Denim is inspired by [phyloFlash](https://github.com/HRGV/phyloFlash).
# Why would you want to do that?

It allows you to assemble full-length ITS sequences for uncultivated eukaryotes. Moreover, since the input is unamplified DNA, it can find ITS sequences of eukaryotes for which existing metabarcoding primers don't work too well.

# Installation
Download the denim files:

```bash
git clone https://github.com/tage-ro/denim.git
cd denim
```

Denim relies on [fastp](https://github.com/OpenGene/fastp), [BBmap](https://archive.jgi.doe.gov/data-and-tools/software-tools/bbtools/), [SPAdes](https://github.com/ablab/spades) and [ITSx](https://microbiology.se/software/itsx/). Install them in a conda virtual environment by running:

```bash
conda env create -n denim --file denim_env.yml
```

You also need an ITS database to map reads to, in FASTA format. I suggest the [UNITE database](https://unite.ut.ee/repository.php).

You will probably want to use the current one for all eukaryotes. Use of the "dev" fasta may result in more complete ITS sequence assembly, as it contains flanking sequences.

Now you have everything you need to run denim. You can test it by replacing <database_path> with the path to your database and running:

```bash
conda activate denim
bash denim.sh -f test_data/PytAspReads_R1.fastq.gz -r test_data/PytAspReads_R2.fastq.gz -d <database_path> -o test_output

```

For convenience, you may want to copy denim.sh to the bin-directory of your conda environment, allowing you to run it from anywhere.

```bash
cp denim.sh /path/to/your/conda/env/denim/bin # Copy the denim executable
cp scripts /path/to/your/conda/env/denim/bin # Copy the extra scripts (for using -c)
denim.sh -h
```

# Troubleshooting
Denim is developed for use on Linux systems on high performance computing clusters. If you run denim on your personal computer, consider limiting the number of reads processed to 1 000 000 (`-n 1000000`).

Denim is developed for paired Illumina reads from (meta)genomic samples. It will not perform well with ITS amplicon sequencing samples, use other software for these. Your mileage with transcriptomic data may vary.

# Planned future additions
* Options to lower the minimum identity in mapping and ITS-extraction steps, to allow for more divergent ITS sequences.
* Please suggest further improvements [here](https://github.com/tage-ro/denim/issues).
