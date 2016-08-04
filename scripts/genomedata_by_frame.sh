#!/usr/bin/env bash

#BSUB -J segregate[1-2]
#BSUB -e log.gen_plot.%J.%I.err
#BSUB -o log.gen_plot.%J.%I.out
#BSUB -q normal

# Split bam file into separate bams based on the length of the aligned read
# Take the stack of bam files generated by the script and generate bedgraphs using bedtools

# Input is 1 bam file
# Output is genomedata archive

set -o nounset -o pipefail -o errexit

SRC_DIR='/vol3/home/elijah/dev/rotations/frameshifting/pipeline'
args=$(getopt -l "strand:sample:input_file:output_file" -o "s:a:i:o:h" -- "$@")

eval set -- "$args"

while [ $# -ge 1 ]; do
    case "$1" in
        --)
        # No more options left.
        shift
        break
        ;;
        -a|--sample)
        sample="$2"
        shift
        ;;
        -i|--input_file)
        input_file="$2"
        shift
        ;;
        -o|--output_file)
        output_file="$2"
        shift
        ;;
        -s|--strand)
        strand="$2"
        shift
        ;;
        -h)
        echo "Display some help"
        exit 0
        ;;
    esac
    shift
done

GENOME_CHROM_SIZES="/vol3/home/elijah/ref/genomes/sacCer1/sacCer1.chrom.sizes"
# bamfile=$input_file
# echo " segreating $bamfile"
# $SRC_DIR/./split_by_read_length.py $bamfile 

frames=('0' '1' '2')
strands=('pos' 'neg')
for frame_idx in "${!frames[@]}"; do

    frame_name=${frames[$frame_idx]}
    for strand_idx in "${!strands[@]}"; do
        strand_name=${strands[$strand_idx]}
        signal="bedgraphs/$sample/by_frame/all.$strand_name.bg.gz"
        frame_map="bedgraphs/frame_map.$frame_name.$strand_name.bg.gz"

        echo "intersecting bedgraphs:"
        echo "$signal with"
        echo "$frame_map"
        bedtools intersect -wa -s -a $signal -b $frame_map\
            | gzip -c \
            > ./bedgraphs/$sample/by_frame/$frame_name.$strand_name.bg.gz
    done
done

GENOME=$HOME/ref/genomes/sacCer1/sacCer1.fa
pos_bgs=$(find "bedgraphs/$sample/by_frame" -name "*pos.bg.gz" ! -name 'all.*' | sort)
neg_bgs=$(find "bedgraphs/$sample/by_frame" -name "*neg.bg.gz" ! -name 'all.*' | sort)
bgs=
idx=0
for i in "${!pos_bgs[@]}"; do
    bgs[idx]=${pos_bgs[$i]}
    idx=$(expr $idx + 1)
    bgs[idx]=${neg_bgs[$i]}
    idx=$(expr $idx + 1)
done

declare -p bgs

trackspec=""
for f in ${bgs[@]}; do
    trackname=$(basename $f '.bg.gz')
    new_track="-t $sample.$trackname=$f "
    trackspec=$trackspec$new_track
done

echo $trackspec
genomedata-load --verbose $trackspec -s $GENOME $output_file
