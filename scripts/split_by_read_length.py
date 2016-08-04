#! /usr/bin/env python3

'''
segregate.py
--------------
'''

from pysam import AlignmentFile

from functools import partial
from collections import Counter, defaultdict, namedtuple
from pathlib import Path as path

# import ipdb
import sys
import re

__version__ = '0.01b'

def rpf_signals(bamfilename, min_length, max_length, verbose):

    output_files = {}
    file_path=path(bamfilename)
    # file_name_rgx = "(.+/)(.+)\.[a-z]{3}\.bam"
    # c_file_rgx = re.compile(file_name_rgx)
    with AlignmentFile(bamfilename, 'rb') as alignfile:
        for aseg in alignfile.fetch():

            # calculate length of aligned read
            alen = rpf_length(aseg)
            if alen >= min_length and alen <= max_length:

                # check if a file for that length exists
                if alen not in output_files.keys():
                    # if it doesn't exist create it
                    # path, outfile = c_file_rgx.findall(bamfilename)[0]
                    output_filename = "%s/seg_by_align_size/%s.all.bam" % (str(file_path.parent), alen)
                    output_files[alen] = AlignmentFile( output_filename,  'wb', template=alignfile)
                    # print >>sys.stderr, '>> opening file %s' %output_filename

                # fetch file_handle for that length
                output_files[alen].write(aseg)

    # write the segment to that file
    for file in output_files.values():
        file.close()

def rpf_length(aseg):
    ''' length of rpf from sam record. takes clipping into
    account?

    Returns: int
    '''
    return aseg.query_alignment_length

def main():

    from argparse import ArgumentParser

    version = "%s" % __version__
    description = ("Split a bam file into multiple files based on criteria")

    parser = ArgumentParser(description=description)

    parser.add_argument("bam_filename", help='BAM filename')

    parser.add_argument("min_length", default=18, type=int, help="Minimum segment alignment length")

    parser.add_argument("max_length", default=34, type=int, help='Maximum segment alignment length')

    parser.add_argument("--verbose", action="store_true",
        default=False, help="verbose output")

    args = parser.parse_args()

    kwargs = {
        'min_length':args.min_length,
        'max_length':args.max_length,
        'verbose':args.verbose
        }

    return rpf_signals(args.bam_filename, **kwargs)

if __name__ == '__main__':
    sys.exit(main())
