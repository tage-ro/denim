#!/bin/sh

# Help message
USAGE="Usage: denim.sh -f FORWARD_READS -r REVERSE_READS -d DATABASE_FILE [-o OUTPUT_DIRECTORY -t THREADS -n N_READS -w WORKING_DIRECTORY -i MINIMUM_IDENTITY -c]
Required arguments:
-f Forward reads in fastq/fastq.gz format
-r Reverse reads in fastq/fastq.gz format
-d ITS database in fasta format

Optional arguments:
-o Output directory (default = denim_out in current directory)
-t Threads to use (default = 8)
-n Reads pairs to process (default = 10 000 000, -n 0 to use all reads)
-w Working directory (default = output_director/tmp)
-i Minimum identity for mapping step (default = 0.5/50%)
-c Filter out complete (not bordering contig edges) ITS1/ITS2 sequences (default = not executed)

Using the dev-version of the UNITE database may allow assembly of ITS-adjacent regions, possibly increasing the likelyhood of attaining full-length ITS sequences.

Created by Tage Rosenqvist, 2025."

if [ "$1" == "-h" ]; then # Return help
  echo "$USAGE"
  exit
fi


# Default values
THREADS=8
N_READS=10000000
TMP_DIR=-1
OUTPUT_DIR="denim_out"
IDENTITY=0.5
GET_COMPLETE=FALSE

# Read options and corresponding values
while getopts "f:r:d:o:t:n:w:i:c" option; do
  case "$option" in
    f) READ_1=${OPTARG} ;; # Forward reads
    r) READ_2=${OPTARG} ;; # Reverse reads
    d) DATABASE=${OPTARG} ;; # Database in .fasta format
    o) OUTPUT_DIR=${OPTARG} ;; # Output directory (default = denim_out)
    t) THREADS=${OPTARG} ;; # Number of threads to use (default = 8 threads)
    n) N_READS=${OPTARG} ;; # Number of reads to process (default = 10 000 000 read pairs)
    w) TMP_DIR=${OPTARG} ;; # Temporary working directory (default = tmp directory in output directory)
    i) IDENTITY=${OPTARG} ;; # Identity required for mapping step (default = 0.5 = 50%)
    c) GET_COMPLETE=TRUE ;;
    *) echo "Unrecognized input option given. Stopping analysis."
    exit;;
  esac
done

# Check if input files exist
if [ ! -f "$READ_1" ]; then
  echo "No forward reads detected. Stopping analysis."
  exit
fi

if [ ! -f "$READ_2" ]; then
  echo "No reverse reads detected. Stopping analysis."
  exit
fi

if [ ! -f "$DATABASE" ]; then
  echo "No database detected. Stopping analysis"
  exit
fi

# Check if output folder exists, otherwise make it
if [ -d "${OUTPUT_DIR}" ]; then
  echo "Output folder exists at" $OUTPUT_DIR
else
  echo "Creating output folder at" $OUTPUT_DIR
  mkdir $OUTPUT_DIR
fi

# Check if working directory was given, otherwise put it in the output folders
if [ "${TMP_DIR}" == -1 ]; then
  TMP_DIR=${OUTPUT_DIR}/tmp
fi

# Check if temporary folder exists, otherwise make it
if [ -d "${TMP_DIR}" ]; then
  echo "Temporary folder exists at" $TMP_DIR
else
  echo "Creating temporary folder at" $TMP_DIR
  mkdir $TMP_DIR
fi

# Abort if output already exists for this file, otherwise continue
NAME=$(basename "${READ_1%_*}")
OUT=${OUTPUT_DIR}/${NAME}

if [ -d "${OUT}" ]; then
  echo ${NAME} " directory already exists, skipping."
  exit
else
  mkdir ${OUT}
fi

echo "Starting analysis of " $NAME " on " $(date)

# Quality control with fastp
if [ $N_READS == 0 ]; then
  fastp -x -D --dup_calc_accuracy 1 -j ${TMP_DIR}/${NAME}.json -h ${TMP_DIR}/${NAME}.html \
    --thread $THREADS -i $READ_1 -I $READ_2 -o ${TMP_DIR}/${NAME}_proc_1.fastq -O ${TMP_DIR}/${NAME}_proc_2.fastq
else
  fastp --reads_to_process $N_READS -x -D --dup_calc_accuracy 1 -j ${TMP_DIR}/${NAME}.json -h ${TMP_DIR}/${NAME}.html \
  --thread $THREADS -i $READ_1 -I $READ_2 -o ${TMP_DIR}/${NAME}_proc_1.fastq -O ${TMP_DIR}/${NAME}_proc_2.fastq
fi

# Mapping with bbmap
bbmap.sh fast=t pairlen=1200 overwrite=t usejni=t ref=$DATABASE threads=$THREADS \
minidentity=$IDENTITY in=${TMP_DIR}/${NAME}_proc_1.fastq in2=${TMP_DIR}/${NAME}_proc_2.fastq \
outm=${TMP_DIR}/${NAME}_mapped_1.fastq outm2=${TMP_DIR}/${NAME}_mapped_2.fastq

# Assembly with megahit
megahit -t $THREADS -1 ${TMP_DIR}/${NAME}_mapped_1.fastq -2 ${TMP_DIR}/${NAME}_mapped_2.fastq -o  ${OUT}/assembled --k-step 4

# ITS extraction with ITSx
ITSx --cpu $THREADS -i ${OUT}/assembled/final.contigs.fa -o ${OUT}/${NAME}

# Filter out ITS1/ITS2 sequences that were detected on edges of contigs, and may thus be incomplete
if [ $GET_COMPLETE == TRUE ]; then
  awk -F "\t" '($3 != "SSU: Not found") && ($5 != "5.8S: Not found") {print $1}' ${OUT}/${NAME}.positions.txt > ${TMP_DIR}/complete_seqs.txt
  grep -A 1 -f ${TMP_DIR}/complete_seqs.txt --no-group-separator ${OUT}/${NAME}.ITS1.fasta > ${OUT}/${NAME}.ITS1.complete.fasta

  awk -F "\t" '($7 != "LSU: Not found") && ($5 != "5.8S: Not found") {print $1}' ${OUT}/${NAME}.positions.txt > ${TMP_DIR}/complete_seqs.txt
  grep -A 1 -f ${TMP_DIR}/complete_seqs.txt --no-group-separator ${OUT}/${NAME}.ITS2.fasta > ${OUT}/${NAME}.ITS2.complete.fasta
fi

# Remove temporary files
rm -r ${TMP_DIR}

echo "Finished analysis of " $NAME " on " $(date)
