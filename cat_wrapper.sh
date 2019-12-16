#!/usr/bin/env bash



usage () {

cat  << EOF
  $0  <input vcf dir> <output dir> 
EOF
}

if [ $# -ne 2  ]; then
  usage
  exit 1
fi

#should be a list of variant input and a chr range file. perhaps chr and number of part to split the computation?

# this should be made an option

module load mugqic/java/openjdk-jdk1.8.0_72
module load mugqic/GenomeAnalysisTK/4.1.2.0

input_dir=${1}
output_dir=${2}

SORTED_FILES=$(lfs find  range_files -name "*vcf" | awk '{printf " -V "$1 }')


java  -cp ${GATK_JAR}  org.broadinstitute.gatk.tools.CatVariants     -R $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/Homo_sapiens.GRCh38.fa   $SORTED_FILES    --outputFile $output_dir    --assumeSorted


