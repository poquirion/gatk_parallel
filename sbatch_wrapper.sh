
usage () {

cat  << EOF
  $0   -V <vcf_list_file>[,<vcf_list_file>] [-c <chr1>[,<chrX>,...]]  <dict> <N hosts> <N CHUNKS> <output directory>
  <dict>:
    File In in the form of Homo_sapiens.GRCh38.dict found in
      /cvmfs/ref.mugqic/genomes/species/Homo_sapiens.GRCh38/genome
  <N hosts>
    How many Host per chromosome, all the cores are taken
  <N CHUNKS>
    Number of chunks per chromosome to split your merge into. Should be at
      least 200 * <N host> so it make sense to use that code.
  <output directory>
    Where the log and the job is keep
  -c
    Only use chr in the coma separated list chr_1,chr_2,chr_X,...
  -e
    Exclude the chr in the coma separated list chr_1,chr_2,chr_X,...
  -r
    Rerun the job found in <output directory>
  -V 
    File with a list of VCF files path to run the merge on

EOF
}

unset CHR_CONTSTRAINT
while getopts ":c:V:re:h" opt; do
  case $opt in
    c)
      IFS=',' read -r -a CHR_CONTSTRAINT <<< "${OPTARG}"
      ;;
    e)
      IFS=',' read -r -a EXCLUDED_CHR <<< "${OPTARG}"
      ;;
    V)
      IFS=',' read -r -a VCF_LISTS <<< "${OPTARG}"
      ;;
    r)
      RERUNING=1
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z $VCF_LISTS ]; then
  echo -V option is not an option!
  usage
  exit 1
fi


shift $((OPTIND-1))

if [ $# -ne 4 ]; then
  usage
  exit 1
fi



INPUT_DICT=$1
CHUNKS=$3
N_HOSTS=$2
VCF_OUTPUT_DIR=$4

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

export INTERVAL_DIR=$VCF_OUTPUT_DIR/intervals
# create one bed file per chr



make_inputs (){

    INPUT_DICT=$1
    CHUNKS=$2
    VCF_OUTPUT_DIR=$3
    shift 3
    VCF_LISTS=$@
    mkdir -p $INTERVAL_DIR
    range_per_chr=($( grep "SN:\(chr\)\?[1-9XY][0-9]*\s"  $INPUT_DICT | sed 's/.*SN:\(chr\)\?\([0-9XY]\+\)\sLN:\([0-9]\+\).*/\2 \3/' ))
    #for VCF_LIST in ${VCF_LISTS[@]}; do 
      for chr in {0..23}; do
        val=$((2*$chr))
        chr_range=(${range_per_chr[@]:$val:2})

        INTERVAL_PATH=$INTERVAL_DIR/chr_${chr_range[0]}

        range=$((${chr_range[1]}/$((CHUNKS-1))))
        previous=1
        rm $INTERVAL_PATH 2> /dev/null
	exec 3> $INTERVAL_PATH
        for ((i="$range" ; i<=${chr_range[1]} ; i+=$range));do

          echo chr${chr_range[0]}:$previous-$i >&3
          previous=$i
        done
          echo chr${chr_range[0]}:$previous-${chr_range[1]} >&3
	  exec 3>&-

      done
    #done
}


mkdir -p ${VCF_OUTPUT_DIR}

if [ -z $RERUNING ]; then 
  make_inputs $INPUT_DICT $CHUNKS $VCF_OUTPUT_DIR ${VCF_LISTS[0]}
else
  echo reruning on $VCF_OUTPUT_DIR directory setup
fi

rdn_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
master_name=vcf_merge_master_${rdn_str}



for file in $INTERVAL_DIR/chr* ; do

    chr=$(basename $file )
    if [ -n "${CHR_CONTSTRAINT}" ]; then
      if ! [[ " ${CHR_CONTSTRAINT[@]} " =~ " ${chr} " ]]; then
        continue
      fi
    fi
    if  [[ " ${EXCLUDED_CHR[@]} " =~ " ${chr} " ]]; then
      continue
    fi

  sbatch_file=$(mktemp /tmp/gnu_parallel_XXXXXX.sh)

#Will test read to var maybe
#read -r -d '' VAR <<'EOF'

  cat << EOF >$sbatch_file
#!/usr/bin/env bash

scontrol show hostname \${SLURM_JOB_NODELIST} > $VCF_OUTPUT_DIR/node_list_\${SLURM_JOB_ID}


parallel --joblog $VCF_OUTPUT_DIR/job_${chr}.log  --resume-failed  --jobs \${SLURM_CPUS_ON_NODE} --sshloginfile \
 ${VCF_OUTPUT_DIR}/node_list_\${SLURM_JOB_ID}  --workdir $PWD --env _  -a $file $SCRIPTPATH/gatk_wrapper.sh  ::: ${VCF_LISTS[@]}
EOF


  sbatch -A $RAP_ID  --time 01:00:00 --mem-per-cpu=4775  --ntasks-per-node=1 --nodes=$N_HOSTS \
     --job-name=$master_name  --output=${VCF_OUTPUT_DIR}/${master_name}.slurm-%j.out  $sbatch_file


done
