#!/usr/bin/env bash
#SBATCH -A def-lathrop
#SBATCH --time 24:00:00
#SBATCH --mem=191000
#SBATCH  --ntasks-per-node=40
#SBATCH  --nodes=3

scontrol show hostname ${SLURM_JOB_NODELIST} > run1/node_list_${SLURM_JOB_ID}

for chr in  $chr/*bed*; do echo $chr ;done  \
| parallel --joblog run1/${chr}.log  --resume-failed  --jobs ${SLURM_CPUS_ON_NODE} --sshloginfile \
 run1/node_list_${SLURM_JOB_ID}  --workdir $PWD --env SLURM_TMPDIR   gatk_wrapper.sh