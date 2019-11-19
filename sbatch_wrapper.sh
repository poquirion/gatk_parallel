
usage () {

cat  << EOF
  $0  <list of .bed files> <vcf output directory>

  if you bed files are all in a directory structure, you can put them in a file with the following command:
	  $ lfs find  \$(realpath ./path_to/bed_files/) -type f -name "*.bed" -ls > my_list_of_bed.txt  
EOF
}

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

export BED_FILES=$1
export VCF_OUTPUT_DIR=$2


mkdir -p ${VCF_OUTPUT_DIR}

rdn_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
master_name=vcf_merge_master_${rdn_str}

echo submit master job
job_id=$(sbatch -A $RAP_ID  --time 1-00:00:00 --mem-per-cpu=4775  --ntasks-per-node=40 --nodes=5 \
       	--job-name=$master_name  --output=${master_name}.slurm-%j.out  parallel_wrapper.sh | awk '{print $NF}' )
echo $job_id submited
