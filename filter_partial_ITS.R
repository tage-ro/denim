args = commandArgs(trailingOnly=TRUE)

sequences <- Biostrings::readDNAStringSet(args[1])
seqnames <- names(sequences)

contig_length <- gsub("^.*length\\_", "", seqnames)
contig_length <- gsub("\\_.*", "", contig_length)

span <- gsub(".*sequence ", "", seqnames)
span <- gsub(" \\(.*", "", span)
span <- as.data.frame(strsplit(span, "-"))

positions <- data.frame(start_seq = as.character(span[1,]), end_seq = as.character(span[2,]), start_cont = "1", end_cont = contig_length)

partial_seqs <- apply(positions, 1, function(x) x[1] == x[3] | x[2] == x[4])

if (sum(!partial_seqs) > 0) {
  new_filename <- gsub("fasta$", "complete.fasta", args[1])
  Biostrings::writeXStringSet(sequences[!partial_seqs], new_filename)
} else {
  print(paste("No complete sequences in", args[1]))
}
