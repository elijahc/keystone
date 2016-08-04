#!/usr/bin/env python

from pybedtools import BedTool
import sys

file_path=sys.argv[1]
frame=sys.argv[2]

for region in BedTool(file_path):
    # chrom, start, end, name, score, strand
    # region.fields
    # ['chrM', '79212', '80022', 'Q0275', '1', '+', '79212', '80022', '0', '1', '810,', '0,', 'Q0275']

    if region.score == frame:
        print '\t'.join(region.fields)

# ouput should be 
# chrom{\t}start{\t}stop
