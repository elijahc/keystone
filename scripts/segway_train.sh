#!/usr/bin/env bash

#BSUB -J segregate[1-2]
#BSUB -e log.gen_plot.%J.%I.err
#BSUB -o log.gen_plot.%J.%I.out
#BSUB -q normal

set -o nounset -o pipefail -o errexit

SRC_DIR='/vol3/home/elijah/dev/rotations/frameshifting/pipeline'
args=$(getopt -l "sample" -o "a:h" -- "$@")

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
        -h)
        echo "Display some help"
        exit 0
        ;;
    esac
    shift
done

NHOME=/vol3/home/elijah
# segment dU and timing data
PROJECT="$NHOME/projects/frameshifting"
# RESULTS="$PROJECT/results/2015-06-11/by_untreated_ribo_seq"

GDARCHIVE="$PROJECT/data/Lareau_2014/$sample.seg.by_frame.genomedata"

strand='seg'
pos_bgs=$(find "bedgraphs/$sample/by_frame" -name "*pos.bg.gz" | grep -v all | sort)
neg_bgs=$(find "bedgraphs/$sample/by_frame" -name "*neg.bg.gz" | grep -v all | sort)
bgs=[]

TRACKSPEC="--tracks-from=$sample.tracks.txt"
COMMONSPEC="--num-labels=7 $TRACKSPEC"
INCLUDEFILENAME="include.bed"
EXCLUDEFILENAME="exclude.bed"
REGIONSPEC="--include-coords=$INCLUDEFILENAME"

TRAINDIRNAME="/vol3/home/elijah/projects/frameshifting/data/Lareau_2014/segway/7-label/$sample.train"
IDENTIFYDIRNAME="/vol3/home/elijah/projects/frameshifting/data/Lareau_2014/segway/7-label/$sample.identify"

cmd="segway --num-instances=3 --reverse-world=1 train $GDARCHIVE $TRAINDIRNAME \
    $COMMONSPEC $REGIONSPEC"

echo $cmd
$cmd
