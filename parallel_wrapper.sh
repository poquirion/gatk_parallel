#!/usr/bin/env bash

scontrol show hostname ${SLURM_JOB_NODELIST} > run1/node_list_${SLURM_JOB_ID}



$BED_FILES

parallel --joblog run1/${chr}.log  --resume-failed  --jobs ${SLURM_CPUS_ON_NODE} --sshloginfile \
 run1/node_list_${SLURM_JOB_ID}  --workdir $PWD --env _   gatk_wrapper.sh


