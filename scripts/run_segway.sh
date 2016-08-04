#! /usr/bin/env bash

#BSUB -J segway.master
#BSUB -o segway.master.%J.out
#BSUB -e segway.master.%J.err
#BSUB -q normal

set -o nounset -o pipefail -o errexit

NHOME=/vol3/home/elijah
# segment dU and timing data
PROJECT="$NHOME/projects/frameshifting"
# RESULTS="$PROJECT/results/2015-06-11/by_untreated_ribo_seq"

sample='SRR1363413'
GDARCHIVE="$PROJECT/data/Lareau_2014/$sample.by_len.seg.genomedata"

strand='seg'
pos_bgs=$(find "bedgraphs/$sample/by_read_len" -name "*pos.bg.gz" | sort)
neg_bgs=$(find "bedgraphs/$sample/by_read_len" -name "*neg.bg.gz" | sort)
bgs=[]
TRACKSPEC=""
case $strand in
    pos)
    bgs=pos_bgs
    ;;
    neg)
    bgs=neg_bgs
    ;;
    seg) 
    idx=0
    for i in "${!pos_bgs[@]}"; do
        pos_track=$(basename "${pos_bgs[${i}]}" '.bg.gz')
        neg_track=$(basename "${neg_bgs[${i}]}" '.bg.gz')
        new_spec="-t $pos_track,$neg_track "
        TRACKSPEC=$TRACKSPEC$new_spec
    done
    ;;
esac

echo $TRACKSPEC

TRACKS="--tracks-from=tracks.txt"
COMMONSPEC="--num-labels=12 $TRACKS"
INCLUDEFILENAME="/vol3/home/elijah/dev/rotations/frameshifting/include.bed"
EXCLUDEFILENAME="/vol3/home/elijah/dev/rotations/frameshifting/exclude.bed"
REGIONSPEC="--include-coords=$INCLUDEFILENAME"

TRAINDIRNAME="/vol3/home/elijah/projects/frameshifting/data/Lareau_2014/$sample.train"
IDENTIFYDIRNAME="/vol3/home/elijah/projects/frameshifting/data/Lareau_2014/$sample.identify"

cmd="segway --num-instances=5 --cluster-opt='-q short' --reverse-world=1 train $GDARCHIVE $TRAINDIRNAME \
    $COMMONSPEC $REGIONSPEC"

echo $cmd
$cmd

#segway identify $GDARCHIVE $TRAINDIRNAME $IDENTIFYDIRNAME \
#   $COMMONSPEC "--exclude-coords=$EXCLUDEFILENAME" \

#segway-layer -b "$IDENTIFYDIRNAME/segway.layered.bb" \
#    "$IDENTIFYDIRNAME/segway.bed.gz" "$IDENTIFYDIRNAME/segway.layered.bed.gz"
