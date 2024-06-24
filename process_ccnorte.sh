#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/bot.conf

log_start "CCNorte"

TEMP_DIR=$(mktemp -d /tmp/ccnorte.XXXXXXX)

for i in {1..4}; do
    wget https://ccnorte.com/evento/index/page/${i}? -O ${TEMP_DIR}/ccnorte_${i}.html
    xmllint --html ${TEMP_DIR}/ccnorte_${i}.html > ${TEMP_DIR}/ccnorte_${i}.clean.html
done

cat ${TEMP_DIR}/*clean.html > ${TEMP_DIR}/all.html

cat ${TEMP_DIR}/all.html | grep -A1 -e 'itemprop="startDate"' -e 'itemprop="url"' --no-group-separator > ${TEMP_DIR}/races.txt

#
# races.txt:
#
# Each race is composed of 4 lines:
#
# 	<span class="evento-sumary-fecha" itemprop="startDate" content="2022-10-02T10:00:00+02:00">
# 	02 oct. 2022                </span>
# 	<a href="/evento/detalle/page/4/id/2245/desafio-boot-camp-vigo-2022" itemprop="url">
# 	<span itemprop="name">DESAFIO BOOT CAMP VIGO 2022</span>
#

convert_date() {
    declare -A months=(["ene."]="01" ["feb."]="02" ["mar."]="03" ["abr."]="04" ["may."]="05" ["jun."]="06" ["jul."]="07" ["ago."]="08" ["sept."]="09" ["oct."]="10" ["nov."]="11" ["dic."]="12")

    input_date="$1"

    day=$(echo $input_date | awk '{print $1}')
    month=$(echo $input_date | awk '{print $2}')
    year=$(echo $input_date | awk '{print $3}')

    # Handle days with ranges like "28-30"
    day=$(echo $day | sed 's/-/\//')

    month_num=${months[$month]}

    output_date="$year-$month_num-$day"

    echo $output_date
}

RACES_DB="${SCRIPT_DIR}/data/carreiras_ccnorte.tsv"

mkdir -p "${SCRIPT_DIR}/data" && touch ${RACES_DB}

while read LINE; do
	read DATE
	DATE=$(echo "${DATE}" | sed 's#^ *##g; s# *</span>$##g')
	DATE=$(convert_date "${DATE}")

	read URL
	URL=$(echo "${URL}" | sed 's#^ *.*href="##g; s#".*$##g')

	count=$(echo "${URL}" | grep -w 'evento/detalle' -c)
	if [ ${count} -eq 1 ]; then
		URL="https://ccnorte.com/${URL}"
	fi

	read NAME
	NAME=$(echo "${NAME}" | sed 's#^ *.*">##g; s#</span>$##g')
    NAME=$(process_name "${NAME}")

	count=$(grep -w -c -F -e "${NAME}" ${RACES_DB})
	if [ $count -eq 0 ]; then
		echo "${DATE};${NAME};${URL}" >> ${RACES_DB}
		send_telegram "$(format_telegram_ccnorte)"
	fi
done < ${TEMP_DIR}/races.txt

rm -rf ${TEMP_DIR}


