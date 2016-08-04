#! /usr/bin/env python
from pybedtools import BedTool
import sys

file_path=sys.argv[1]

for region in BedTool(file_path):
    # chrom, start, end, name, score, strand
    # region.fields
    # ['chrM', '79212', '80022', 'Q0275', '1', '+', '79212', '80022', '0', '1', '810,', '0,', 'Q0275']
    chrom = region.chrom
    start = region.start
    end = region.end
    name = region.name
    strand = region.strand
    cds_start = int(region.fields[6])
    cds_end = int(region.fields[7])
    num_blocks = int(region.fields[9])
    block_lens = region.fields[10].split(',')
    

    if region.strand == '+':
        coords = range(region.start, region.end+1)
        mods = [(i-cds_start) % 3 for i in coords]
        for start,mod in zip(coords, mods):
            fields = (region.chrom, start, start+1, region.name, mod, region.strand)
            print '\t'.join(map(str, fields)) 
