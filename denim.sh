#!/bin/sh

USAGE="Usage: denim.sh -f FORWARD_READS -r REVERSE_READS -d DATABASE_DIRECTORY -o OUTPUT_DIRECTORY (-t THREADS -n N_READS -w WORKING_DIRECTORY)
Forward and reverse reads can be in fastq or fastq.gz format. The ITS database should be in fasta format. 
Using the dev-version of UNITE may allow assembly of ITS-adjacent regions, possibly increasing the likelyhood of attaining full-length ITS sequences.
Arguments in parantheses are not required.
Created by Tage Rosenqvist, 2025."

# Read options and corresponding values
while getopts "h:f:r:d:o:t:n:w:" option; do
case "$option" in
h) echo $USAGE
  exit;; # Return help
f) READ_1=${OPTARG} ;; # Forward reads
r) READ_2=${OPTARG} ;; # Reverse reads
d) DATABASE=${OPTARG} ;; # Database in .fasta format
o) OUTPUT_DIR=${OPTARG} ;; # Output directory
t) THREADS=${OPTARG:=16} ;; # Number of threads to use (default = 16 threads)
n) N_READS=${OPTARG:=10000000} ;; # Number of reads to process (default = 10 000 000 reads)
w) TMP_DIR=${OPTARG:=${OUTPUT_DIR}/tmp} ;; # Temporary working directory (default = tmp directory in output directory)
esac
done

# Check if temporary folder exists, otherwise make it
if [ -d "${TMP_DIR}" ]; then
echo "Temporary folder exists at " $TMP_DIR
else
echo "Creating temporary folder at " $TMP_DIR
mkdir $TMP_DIR
fi

# Abort if output folder already exists for this file, otherwise continue
NAME=$(basename "${READ_1%_*}")
OUT=${OUTPUT_DIR}/${NAME}

if [ -d "${OUT}" ]; then
echo ${NAME} " directory already exists, skipping."
else
mkdir ${OUT}

echo "Starting analysis of " $NAME " on " $(date)

# Quality control with fastp
fastp --reads_to_process $N_READS -x -D --dup_calc_accuracy 1 -j ${TMP_DIR}/${NAME}.json -h ${TMP_DIR}/${NAME}.html \
  --thread $THREADS -i $READ_1 -I $READ_2 -o ${TMP_DIR}/${NAME}_proc_1.fastq -O ${TMP_DIR}/${NAME}_proc_2.fastq

# Mapping with bbmap
bbmap.sh fast=t pairlen=1200 overwrite=t usejni=t ref=$DATABASE threads=$THREADS \
minidentity=0.7 in=${TMP_DIR}/${NAME}_proc_1.fastq in2=${TMP_DIR}/${NAME}_proc_2.fastq \
outm=${TMP_DIR}/${NAME}_mapped_1.fastq outm2=${TMP_DIR}/${NAME}_mapped_2.fastq

# Assembly with metaspades (assuming 2 GB RAM available per thread)
spades.py --meta -t $(($THREADS/2)) -m $(($THREADS*2)) -1 ${TMP_DIR}/${NAME}_mapped_1.fastq -2 ${TMP_DIR}/${NAME}_mapped_2.fastq -o ${OUT}/spades

# ITS extraction with ITSx
ITSx --cpu $THREADS -i ${OUT}/spades/contigs.fasta -o ${OUT}/${NAME}

# Remove temporary files
rm ${TMP_DIR}/${NAME}_proc* ${TMP_DIR}/${NAME}_mapped*

echo "Finished analysis of " $NAME " on " $(date)

fi
