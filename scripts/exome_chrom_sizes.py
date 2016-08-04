#! /usr/bin/env python
from pybedtools import BedTool
import sys

file_path=sys.argv[1]

for region in BedTool(file_path):
    # chrom, start, end, name, score, strand
    # region.fields
    # ['chrM', '79212', '80022', 'Q0275', '1', '+', '79212', '80022', '0', '1', '810,', '0,', 'Q0275']
    chrom = region.chrom
    start = int(region.start)
    end = int(region.end)
    name = region.name
    score = int(region.fields[4])
    strand = region.strand
    cds_start = int(region.fields[6])
    cds_end = int(region.fields[7])
    num_blocks = int(region.fields[9])
    block_sizes = region.fields[10]
    block_starts = region.fields[11]
    
    fields = (region.name, end-start+1)
    print '\t'.join(map(str, fields)) 
