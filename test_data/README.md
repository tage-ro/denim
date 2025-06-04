Some test data you can try, generated using [InSilicoSeq](https://github.com/HadrienG/InSilicoSeq). It composed of 700 000 reads, generated from the refseq genomes of an oomycete (*Pythium oligandrum*) and a fungus (*Aspergillus niger*). In this data, they are equally abundant.
* https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_020085045.1/
* https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000002855.4/

The command used to make this test data was:
```bash
sed 's/N//g' GCA_020085045.1_PO-1_genomic.fna > GCA_020085045.1_PO-1_genomic_noN.fna # Remove N residues
sed 's/N//g' GCA_000002855.2_ASM285v2_genomic.fna > GCA_000002855.2_ASM285v2_genomic_noN.fna # Remove N residues
iss generate --draft GCA_020085045.1_PO-1_genomic_noN.fna GCA_000002855.2_ASM285v2_genomic_noN.fna \
--abundance_file abundance.txt -n 700000 --model novaseq --output PytAspReads --cpus 10
gzip PytAspReads_R1.fastq
gzip PytAspReads_R2.fastq

```

You should get two full length ITS sequences by replacing the path to the database and running:
```bash
bash denim.sh -f test_data/PytAspReads_R1.fastq.gz -r test_data/PytAspReads_R2.fastq.gz -d test_data/sh_general_release_dynamic_all_19.02.2025_dev.fasta -o test_output
```

You can verify the identity of the sequences by BLASTing.

These files are small enough to analyze on a personal computer.
