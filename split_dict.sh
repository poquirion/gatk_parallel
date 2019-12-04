#!/bin/bash

INPUT_DICT=/tmp/cvmfs_wycov/mnt/ref.mugqic//genomes/species/Homo_sapiens.GRCh38/genome/Homo_sapiens.GRCh38.dict
CHUNKS=100

range_per_chr=($( grep "chr[1-9XY][0-9]*\s"  $INPUT_DICT | sed 's/.*SN:chr\([0-9XY]\+\)\sLN:\([0-9]\+\).*/\1 \2/' ))

# create one bed file per chr
export INTERVAL_DIR=./intervals
mkdir -p $INTERVAL_DIR

for chr in {0..23}; do
   val=$((2*$chr))
   chr_range=(${range_per_chr[@]:$val:2})

   INTERVAL_PATH=$INTERVAL_DIR/chr_${chr_range[0]}

   range=$((${chr_range[1]}/$((CHUNKS-1))))
   previous=1
   rm $INTERVAL_PATH 2> /dev/null
   for ((i="$range" ; i<=${chr_range[1]} ; i+=$range));do 
       
       echo chr${chr_range[0]}:$previous-$i >> $INTERVAL_PATH
       previous=$i
   done    
       echo chr${chr_range[0]}:$previous-${chr_range[1]} >> $INTERVAL_PATH
   
done

