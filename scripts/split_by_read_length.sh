#!/usr/bin/env bash

args=$(getopt -l "sample:input_file:min_len:max_len" -o "a:i:n:x:h" -- "$@")

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
        -n|--min_len)
        min_len="$2"
        shift
        ;;
        -x|--max_len)
        max_len="$2"
        shift
        ;;
        -h)
        echo "Display some help"
        exit 0
        ;;
    esac
    shift
done

if [[ ! -d "alignments/$sample/seg_by_align_size" ]]; then
    mkdir -p "alignments/$sample/seg_by_align_size"
fi

SRC_DIR='/vol3/home/elijah/dev/rotations/frameshifting/pipeline'

bamfile=$input_file
echo " segreating $bamfile"
$SRC_DIR/./split_by_read_length.py $bamfile $min_len $max_len
