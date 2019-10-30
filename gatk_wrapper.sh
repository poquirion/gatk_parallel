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

# this should be made an option
A1=`for i in /lustre04/scratch/wcheung/vcf/Immunoseq_CD/*gvcf.gz;do echo  " --variant $i \ ";done`;
A2=`for i in /lustre04/scratch/wcheung/vcf/15a-CD_M_George/*gvcf.gz;do echo  " --variant $i \ ";done`;

module load mugqic/java/openjdk-jdk1.8.0_72

CHR_RANGE_FILE=${1}

java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 \
-Dsamjdk.buffer_size=8192 -Xmx4775M  \
-jar $MUGQIC_INSTALL_HOME/software/GenomeAnalysisTK/GenomeAnalysisTK-4.1.2.0/gatk-package-4.1.2.0-local.jar \
CombineGVCFs -R $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh37/genome/Homo_sapiens.GRCh37.fa \ $A1 $A2
-O ${VCF_OUTPUT_DIR}/combinedCD.${CHR_RANGE_FILE}.gvcf -L ${CHR_RANGE_FILE}
