#!/usr/bin/env bash



usage () {

cat  << EOF
  $0  <path to interval file>
EOF
}

if [ $# -ne 1  ]; then
  usage
  exit 1
fi

#should be a list of variant input and a chr range file. perhaps chr and number of part to split the computation?

# this should be made an option
l1=(/lustre04/scratch/wcheung/vcf/Immunoseq_CD/*gvcf.gz)
l2=(/lustre04/scratch/wcheung/vcf/15a-CD_M_George/*gvcf.gz)
A1=`for i in ${l1};do printf  " --variant $i ";done`;
A2=`for i in ${l2};do printf  " --variant $i ";done`;

module load mugqic/java/openjdk-jdk1.8.0_72
module load mugqic/GenomeAnalysisTK/4.1.2.0

CHR_RANGE_FILE=${1}

bed_file_name=$(basename "${CHR_RANGE_FILE}")

java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 \
 -Dsamjdk.buffer_size=8192 -Xmx4775M  \
 -jar ${GATK_JAR} \
 CombineGVCFs -R $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh37/genome/Homo_sapiens.GRCh37.fa \
 $A1 $A2 \
-O ${VCF_OUTPUT_DIR}/combinedCD.${bed_file_name}.gvcf -L ${CHR_RANGE_FILE}
