#! /usr/bin/env python
from pybedtools import BedTool

file_path='/vol3/home/elijah/dev/assemblyhub/sacCer1_ext/rna/gene-models.old/mRNAs.trim.bed'

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
    

    if region.strand == '-':
        coords = range(region.start, region.end+1)
        mods = [i % 3 for i in coords]
        for start,mod in zip(coords, reversed(mods)):
            fields = (region.chrom, start, start+1, region.name, mod, region.strand)
            print '\t'.join(map(str, fields)) 
