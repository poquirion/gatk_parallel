for chr in  ../all_bed_files/*; do

  export chr
  echo $chr
  echo sbatch --job-name=$chr.run --output=$chr.slurm-%j.out  parallel_wrapper.sh

done
