#!/usr/bin/env bash


MASTER_JOB_ID=$1

cleanup () {

sed -i run1/node_list_$1  '/${SLURM_JOB_CPUS_PER_NODE}/${SLURM_JOB_NODELIST}/d'

}
trap cleanup EXIT


scontrol show hostname "${SLURM_JOB_CPUS_PER_NODE}/${SLURM_JOB_NODELIST}" > run1/node_list_$1