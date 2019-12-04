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

module load mugqic/java/openjdk-jdk1.8.0_72
module load mugqic/GenomeAnalysisTK/4.1.2.0

CHR_RANGE=${1}
VARIANT_FILE=${2}
VCFS=$(for i in ${l1};do printf  " --variant $i ";done < ${sVARIANT_FILE})

# make VCF_OUTPUT_DIR an input ?, probably, not

java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 \
 -Dsamjdk.buffer_size=8192 -Xmx4775M  \
 -jar ${GATK_JAR} \
 CombineGVCFs -R $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh37/genome/Homo_sapiens.GRCh37.fa \
 $VCFS \
-O ${VCF_OUTPUT_DIR}/combinedCD.${CHR_RANGE/:/-}.gvcf -L ${CHR_RANGE}
