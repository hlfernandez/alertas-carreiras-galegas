#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/bot.conf

BASE_URL="http://carreirasgalegas.com/"
RACES_DB="${SCRIPT_DIR}/data/carreiras_carreiras_galegas.tsv"

RACES=$(mktemp /tmp/races.XXXXXXX)
INPUT=$(mktemp /tmp/calendario.XXXXXXX)

wget "${BASE_URL}/calendario" -O ${INPUT} --no-check-certificate

mkdir -p "${SCRIPT_DIR}/data" && touch ${RACES_DB}

cat ${INPUT} | grep '<td' > ${RACES}

while read LINE; do
	DATE=$(echo "${LINE}" | sed 's#<td.*2">##g; s#</td>.*##g')

	read NAME_LINE
	NAME_LINE=$(echo "${NAME_LINE}" | sed 's#<td.*6">##g; s#</td>.*##g')

	NAME=$(echo "${NAME_LINE}" | sed "s#<a href=.*'>##g; s#</a>##g")
	LINK=$(echo "${NAME_LINE}" | sed "s#.*'/##g" | sed "s#'.*##g")
	LINK=${BASE_URL}${LINK}

	read PLACE
	PLACE=$(echo "${PLACE}" | sed 's#<td.*2">##g; s#</td>.*##g')

	count=$(grep -w -c -F -e "${NAME}" ${RACES_DB})
	if [ $count -eq 0 ]; then
		echo "${DATE};${NAME};${LINK};${PLACE}" >> ${RACES_DB}
		send_telegram "$(format_telegram_carreiras_galegas)"
	fi
done < ${RACES}

rm -f ${RACES} ${INPUT}
