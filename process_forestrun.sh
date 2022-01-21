#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/bot.conf

TEMP_DIR=$(mktemp -d /tmp/forestrun.XXXXXXX)

wget wget https://forestrun.es/ -O ${TEMP_DIR}/forestrun.html
xmllint --html ${TEMP_DIR}/forestrun.html > ${TEMP_DIR}/forestrun.clean.html

grep -e 'content-title' -e '<span class="ev-day">' ${TEMP_DIR}/forestrun.clean.html | sed -e '1d' > ${TEMP_DIR}/races.txt

YEAR=$(grep 'Tu calendario' ${TEMP_DIR}/forestrun.clean.html | sed 's#.*<br>##; s#</.*##')

#
# races.txt:
#
# Each race is composed of 2 lines:
#
# <span class="ev-day">23</span> <span class="ev-mo">Ene</span>
# <h2 class="content-title"><a class="ect-event-url" href="https://forestrun.es/carrera-trail-galicia/vii-trail-andaina-de-cela-bueu-2020/" rel="bookmark">VII TRAIL/ANDAINA DE CELA BUEU 2022</a></h2>
#
#

RACES_DB="${SCRIPT_DIR}/data/carreiras_forestrun.tsv"

mkdir -p "${SCRIPT_DIR}/data" && touch ${RACES_DB}

while read LINE1; do
	read LINE2

	DAY=$(echo ${LINE1} | sed 's#.*ev-day">##g; s#</span>.*##')
	MONTH=$(echo ${LINE1} | sed 's#.*ev-mo">##g; s#</span>.*##')
	DATE="${DAY} ${MONTH} ${YEAR}"
	
	URL=$(echo ${LINE2} | grep -o 'https://forestrun.es/carrera-trail-galicia/.*/"'  | sed -e 's#/"##g')
	NAME=$(echo ${LINE2} | sed -e 's#.*">##; s#</.*##g')
	
    NAME=$(process_name "${NAME}")

	count=$(grep -w -c -F -e "${NAME}" ${RACES_DB})
	if [ $count -eq 0 ]; then
		echo "${DATE};${NAME};${URL}" >> ${RACES_DB}
		send_telegram "$(format_telegram_forestrun)"
	fi
done < ${TEMP_DIR}/races.txt

rm -rf ${TEMP_DIR}


