#!/usr/bin/env bash

scontrol show hostname ${SLURM_JOB_NODELIST} > $VCF_OUTPUT_DIR/node_list_${SLURM_JOB_ID}



parallel --joblog $VCF_OUTPUT_DIR/job.log  --resume-failed  --jobs ${SLURM_CPUS_ON_NODE} --sshloginfile \
 $VCF_OUTPUT_DIR/node_list_${SLURM_JOB_ID}  --workdir $PWD --env _   -a ${BED_FILES} ./gatk_wrapper.sh 


