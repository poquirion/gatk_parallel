
usage () {

cat  << EOF
  $0  <vcf output directory>
EOF
}

if [ $# -ne 1  ]; then
  usage
  exit 1
fi



export {VCF_OUTPUT_DIR}=$1

mkdir -p ${VCF_OUTPUT_DIR}


for chr in  ../all_bed_files/*; do

  export chr
  echo $chr
  echo sbatch --job-name=$chr.run --output=$chr.slurm-%j.out  parallel_wrapper.sh

done
