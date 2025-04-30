#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [-i] [-l LOG_DIR] [-p PROJECT_DIR]

  -i              Prompt interactively for LOG_DIR and PROJECT_DIR
  -l LOG_DIR      Directory for Slurm logs (stdout & stderr)
  -p PROJECT_DIR  Root of your project (where eval_mdm.sh lives)
  -m MAIL_USER    User to send job notifications to
EOF
  exit 1
}

INTERACTIVE=false
LOG_DIR=""
PROJECT_DIR=""
MAIL_USER=""

while getopts "il:p:m:" opt; do
  case $opt in
    i) INTERACTIVE=true ;;
    l) LOG_DIR=$OPTARG ;;
    p) PROJECT_DIR=$OPTARG ;;
    m) MAIL_USER=$OPTARG ;;
    *) usage ;;
  esac
done

if $INTERACTIVE; then
  read -r -p "Log directory for Slurm output: " LOG_DIR
  read -r -p "Project directory (where you’ll cd into): " PROJECT_DIR
fi

# validate
if [[ -z "$LOG_DIR" || -z "$PROJECT_DIR" ]]; then
  echo "ERROR: both LOG_DIR and PROJECT_DIR must be set." >&2
  usage
fi

# submit the job
sbatch \
  --job-name=mdm_eval \
  --gres=gpu:1 \
  --cpus-per-task=4 \
  --mem=32G \
  --time=02:00:00 \
  --partition=mig \
  --mail-type=BEGIN,END,FAIL \
  --mail-user=${MAIL_USER} \
  --output="${LOG_DIR}/ev_mdm_%j.out" \
  --error="${LOG_DIR}/ev_mdm_%j.err" \
  --wrap="\

module load anaconda/2024.06; \
source activate mdm; \
cd ${PROJECT_DIR}; \
bash eval_mdm.sh \
  --tasks hellaswag,openbookqa,arc_easy,boolq,piqa,social_iqa,race,lambada_standard \
  --model_args model_name=1028,ckpt_path=models/mdm_safetensors/mdm-1028M-100e18.safetensors \
  --device cuda:0
"

echo "Submitted mdm_eval to Slurm; logs → ${LOG_DIR}/ev_mdm_<JOBID>.{out,err}"
