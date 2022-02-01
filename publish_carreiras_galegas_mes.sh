#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/bot.conf

if [ $# != 1 ]; then
    show_error "Erro: este script requere un argumento (nome do mes).\n"
fi

MES=$1
RACES_DB="${SCRIPT_DIR}/data/${MES}/carreiras_carreiras_galegas.tsv"

MESSAGE="Carreiras de ${MES} en Carreiras Galegas"
MESSAGE="*${MESSAGE}*"

FILTER=$(get_month_carreiras_galegas ${MES})

if [ "${FILTER}" == "NA" ]; then
	echo "Mes inválido: ${MES}"
	exit 1;
fi

mkdir -p "${SCRIPT_DIR}/data/${MES}" && rm -f ${RACES_DB}
grep -F "${FILTER}" "${SCRIPT_DIR}/data/carreiras_carreiras_galegas.tsv" > ${RACES_DB}

while read LINE
do
	DATE=$(echo "${LINE}" | awk -F';' '{print $1}')
	NAME=$(echo "${LINE}" | awk -F';' '{print $2}')
	LINK=$(echo "${LINE}" | awk -F';' '{print $3}')
	PLACE=$(echo "${LINE}" | awk -F';' '{print $4}')

	NEW_RACE=$(format_telegram_carreiras_galegas)

	MESSAGE="${MESSAGE}%0A%0A${NEW_RACE}"
done < ${RACES_DB}

send_telegram "${MESSAGE}"
