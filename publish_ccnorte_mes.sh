#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/bot.conf.test

MES=$1
RACES_DB="${SCRIPT_DIR}/data/${MES}/carreiras_ccnorte.tsv"

MESSAGE="Carreiras de ${MES} en Champion Chip Norte"
MESSAGE="*${MESSAGE}*"

FILTER=$(get_month_ccnorte ${MES})

if [ "${FILTER}" == "NA" ]; then
	echo "Mes inválido: ${MES}"
	exit 1;
fi

mkdir -p "${SCRIPT_DIR}/data/${MES}" && rm -f ${RACES_DB}
grep -F "${FILTER}" "${SCRIPT_DIR}/data/carreiras_ccnorte.tsv" > ${RACES_DB}

while read LINE
do
	DATE=$(echo "${LINE}" | awk -F';' '{print $1}')
	NAME=$(echo "${LINE}" | awk -F';' '{print $2}')
	URL=$(echo "${LINE}" | awk -F';' '{print $3}')

	NEW_RACE=$(format_telegram_ccnorte)

	MESSAGE="${MESSAGE}%0A%0A${NEW_RACE}"
done < ${RACES_DB}

send_telegram "${MESSAGE}"
