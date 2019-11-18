
usage () {

cat  << EOF
  $0  <vcf output directory>
EOF
}

if [ $# -ne 1  ]; then
  usage
  exit 1
fi

export BED_FILES=~/home/tmp/bed.list
mkdir -p ~/home/tmp

if [ ! -f "$FILE" ] ; then
    lfs find  all_bed_files/ -type f -name "*.bed.???"  |  head  > ${BED_FILES}
fi

export {VCF_OUTPUT_DIR}=$1

mkdir -p ${VCF_OUTPUT_DIR}

rdn_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
master_name=vcf_merge_master_${rdn_str}
mkd

echo submit master job
job_id=$(sbatch -A def-lathrop --time 12:00:00 --mem-per-cpu=4775  --ntasks-per-node=40 --nodes=3  --job-name=$chr.run
  --output=$chr.slurm-%j.out  --name  ${} parallel_wrapper.sh | awk '{print $NF}' )

