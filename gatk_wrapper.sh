#!/usr/bin/env bash



usage () {

cat  << EOF
  $0  <path to interval file>
EOF
}

if [ $# -ne 2  ]; then
  usage
  exit 1
fi

#should be a list of variant input and a chr range file. perhaps chr and number of part to split the computation?

# this should be made an option

module load mugqic/java/openjdk-jdk1.8.0_72
module load mugqic/GenomeAnalysisTK/3.7
mkdir -p ${VCF_OUTPUT_DIR}/output

CHR_RANGE=${1}
VARIANT_FILE=${2}
VCFS=$(while read i ;do printf  " --variant $i ";done < ${VARIANT_FILE})

# make VCF_OUTPUT_DIR an input ?, probably, not

java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 \
 -Dsamjdk.buffer_size=8192 -Xmx4775M  \
 -jar ${GATK_JAR} \
 --analysis_type  CombineGVCFs -R /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.GRCh38/genome/Homo_sapiens.GRCh38.fa \
 --disable_auto_index_creation_and_locking_when_reading_rods \
 $VCFS -l DEBUG \
 --out ${VCF_OUTPUT_DIR}/output/combinedCD.${CHR_RANGE/:/-}.vcf --intervals ${CHR_RANGE}
