#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh

set -a
. ${SCRIPT_DIR}/bot.conf
set +a

log_start "forestrun"

source ${SCRIPT_DIR}/races/.venv/bin/activate

${SCRIPT_DIR}/races/.venv/bin/python ${SCRIPT_DIR}/races/forestrun.py ${SCRIPT_DIR}/data/carreiras_forestrun.2.tsv
