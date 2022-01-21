#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/bot.conf

RACES_DB="${SCRIPT_DIR}/data/to_publish_carreiras_forestrun.tsv"

count=$(wc -l ${RACES_DB} | awk '{print $1}')

if [ ${count} -ge 1 ]; then
	LINE=$(head -1 ${RACES_DB})
	
	DATE=$(echo "${LINE}" | awk -F';' '{print $1}')
	NAME=$(echo "${LINE}" | awk -F';' '{print $2}')
	URL=$(echo "${LINE}" | awk -F';' '{print $3}')

	send_telegram "$(format_telegram_forestrun)"

	sed -i 1d ${RACES_DB}
fi
