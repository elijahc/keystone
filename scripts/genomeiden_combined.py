import pdb
import re
import sys

from pyfaidx import Fasta

if len(sys.argv) < 2 or len(sys.argv) > 3:
    msg = 'error: wrong number of args \n\
    EXAMPLE:   genomeiden_combined.py my_fasta.fa [OPTIONS]'
    print >>sys.stderr, msg
    sys.exit(1)

options = { 'windowed': False }
# genomeiden_combined.py my_fasta.fa [OPTIONS]
fasta_filename = sys.argv[1] 
if len(sys.argv) >2:
    coord_format = sys.argv[2] 

    if coord_format == '--windowed':
        options['windowed'] = True

test_fasta = Fasta(fasta_filename)

names = test_fasta.keys()
print names
def find_all_slippery_seq(seq,n=7):
   
    slippery_seqs = []
    seqs = []

	# searches for slip seq every nucleotide 
    for i in xrange(len(seq)): 
        # forward and revcomp seqs
        strands = ('+', '-')
        starts = (i, i + n) 
        zipped_seqs = zip( (seq[i:i+n], -seq[i:i+n]), strands, starts )
        map(seqs.append,  zipped_seqs)
    i = 0 
    for zseq, zstrand, zidx in seqs:
        slip_seq_test = slippery_seq_regex(str(zseq))
         
        if slip_seq_test:
            slip_seq_test_tup = (zidx, slip_seq_test, zstrand)    
            slippery_seqs.append(slip_seq_test_tup)
        i = i + 1
     
    
    return slippery_seqs
			
# regex to find slip seq matches
complied_rgx = re.compile('((?:AAA|CCC|GGG|TTT)(?:AAA|TTT)[ATC])')

def slippery_seq_regex(seq):
    match = complied_rgx.findall(seq)

    if match:
        return match[0]  
	
def format_7mer_slip_seq(slip_seq_test):
	# formats matches to A|AAA|AAA|
    pt1 = slip_seq_test[0:1]
    pt2 = slip_seq_test[1:4]
    pt3 = slip_seq_test[4:7]
    pipe = '|'
    return ''.join((pt1, pipe, pt2, pipe, pt3, pipe))



for name in test_fasta.keys():
    fa_sequence = test_fasta[name][:] 
      
    for hit in find_all_slippery_seq(fa_sequence):
        #pos, seq, strand = hit 
        formatted_7mer_hit = format_7mer_slip_seq(hit[1])
        if options['windowed']:
            fields = (name, hit[0], hit[0]+6, formatted_7mer_hit, '0', hit[2])
        else:
            fields = (name, hit[0], hit[0]+1, formatted_7mer_hit, '0', hit[2])

        print '\t'.join(map(str, fields))

        # rows.append("\t".join((name,str(pos),str(pos+6),formatted_7mer_hit,'.',strand))

    # print '\n'.join(rows)
