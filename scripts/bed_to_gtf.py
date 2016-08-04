#! /usr/bin/env python
from pybedtools import BedTool
import sys

source=sys.argv[1]

for region in BedTool(source):
    # chrom, start, end, name, score, strand
    # region.fields
    # ['chrM', '79212', '80022', 'Q0275', '1', '+', '79212', '80022', '0', '1', '810,', '0,', 'Q0275']
    chrom = region.chrom
    start = region.start
    end = region.end
    name = region.name
    strand = region.strand
    #cds_start = int(region.fields[6])
    #cds_end = int(region.fields[7])
    #num_blocks = int(region.fields[9])
    #block_lens = region.fields[10].split(',')
    

    # chr1	transcribed_unprocessed_pseudogene  gene        11869 14409 . + . gene_id "ENSG00000223972"; gene_name "DDX11L1"; gene_source "havana"; gene_biotype "transcribed_unprocessed_pseudogene"; 
    # chrom	source	[gene, variation, similarity] start end score strand frame [attributes key "value";]
    fields = (region.chrom, 'slippery_sequences', name, start, end, '.', strand, '.', 'gene_id "'+chrom+'"; transcript_id "'+chrom+'";')
    print '\t'.join(map(str, fields)) 
