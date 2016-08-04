#! /usr/bin/env bash

#BSUB -J segway.master
#BSUB -o segway.master.%J.out
#BSUB -e segway.master.%J.err
#BSUB -q normal

set -o nounset -o pipefail -o errexit

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

segway identify $GDARCHIVE $TRAINDIRNAME $IDENTIFYDIRNAME \
   $COMMONSPEC \
  -i "$TRAINDIRNAME/params/input.master" \
  -p "$TRAINDIRNAME/params/params.params" \
  -s "$TRAINDIRNAME/segway.str"

