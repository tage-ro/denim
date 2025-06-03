Some test data you can try, generated using InSilicoSeq. It composed of 1 000 000 reads, generated from the refseq genomes of two oomycetes: Phytophthora infestans and Pythium insidiosum:
* https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000142945.1/
* https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_022836835.1/

The command used to make this test data was:
```bash
sed 's/N//g' GCA_000142945.1_ASM14294v1_genomic.fna > GCA_000142945.1_ASM14294v1_genomic_noN.fna
sed 's/N//g' GCA_022836835.1_ASM2283683v1_genomic.fna > GCA_022836835.1_ASM2283683v1_genomic_noN.fna
iss generate --draft GCA_000142945.1_ASM14294v1_genomic_noN.fna GCA_022836835.1_ASM2283683v1_genomic_noN.fna \
--abundance_file abundance.txt -n 1000000 --model novaseq --output PhyPytReads_ --cpus 10

```

You should get two full length ITS sequences by replacing the path to the database and running:
```bash
bash denim.sh -f test_data/PhyPytReads_R1.fastq.gz -r test_data/PhyPytReads_R2.fastq.gz -d test_data/sh_general_release_dynamic_all_19.02.2025_dev.fasta -o test_output
```

You can verify the identity of the sequences by BLASTing.

These files are small enough to analyze on a personal computer.
