#!/bin/bash

wget -q --spider http://google.com

if [ $? -ne 0 ]; then
	exit 0
fi

SCRIPT_DIR=$(dirname "$0")

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/bot.conf

log_start "Sportsmaniacs"

TEMP_DIR=$(mktemp -d /tmp/sportsmaniacs.XXXXXXX)

function get_races() {
	curl "https://sportmaniacs.com/es/races/search/${1}" \
		-H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:104.0) Gecko/20100101 Firefox/104.0' \
		-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
		-H 'Accept-Encoding: gzip, deflate, br' -H 'Referer: https://sportmaniacs.com/es/races' \
		-H 'Connection: keep-alive' \
		-H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Sec-GPC: 1' \
		--output "${2}/${1}.gzip"
	sleep 2
}

get_races "a-coruna" ${TEMP_DIR}
get_races "pontevedra" ${TEMP_DIR}
get_races "ourense" ${TEMP_DIR}
get_races "lugo" ${TEMP_DIR}

zcat ${TEMP_DIR}/*.gzip > ${TEMP_DIR}/all.html

xmllint --html ${TEMP_DIR}/all.html > ${TEMP_DIR}/all_clean.html

cat ${TEMP_DIR}/all_clean.html | grep --no-group-separator -P -A1 'data-race-card|card-title card-link|datetime' | grep -v '\- <time' > ${TEMP_DIR}/races.txt

#
# races.txt:
#
# Each race is composed of 6 lines (last is empty):
#
#    <article data-race-card='{"id":"5fa4434d-79a8-4b3b-963a-33faac1f158c","name":"Media Marat\u00f3n de Vigo 2021","brand":"0","category":"Inscription","list":"SearchRacesByProvince:::es"}'>
#        <a data-event="Ver carrera" class="card raceCard card--interactive" href="/es/races/media-maraton-de-vigo-2021">
#                        <h3 class="card-title card-link">
#                            Media Marat&oacute;n de Vigo 2021
#                            <time datetime="2021-11-07 00:00:00">07 nov 2021</time>
#	# blank line                            

convert_date() {
    declare -A months=(["ene"]="01" ["feb"]="02" ["mar"]="03" ["abr"]="04" ["may"]="05" ["jun"]="06" ["jul"]="07" ["ago"]="08" ["sep"]="09" ["oct"]="10" ["nov"]="11" ["dic"]="12")

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

RACES_DB="${SCRIPT_DIR}/data/sportmaniacs.tsv"

mkdir -p "${SCRIPT_DIR}/data" && touch ${RACES_DB}

while read LINE; do
	DATA_RACE_CARD=${LINE}
	read URL
	URL=$(echo "${URL}" | sed 's#^ *.*href="##g; s#".*$##g')
	URL="https://sportmaniacs.com${URL}"
	read IGNORE
	read NAME
	read DATE
	DATE=$(echo ${DATE} | grep -o -P '>[0-9]+.*<' | tr -d '>' | tr -d '<')
	DATE=$(convert_date "${DATE}")
	read IGNORE

    NAME=$(process_name "${NAME}")

	count=$(grep -w -c -F -e "${NAME}" ${RACES_DB})
	if [ $count -eq 0 ]; then
		echo "${DATE};${NAME};${URL}" >> ${RACES_DB}
		send_telegram "$(format_sportmaniacs)"
	fi
done < ${TEMP_DIR}/races.txt

rm -rf ${TEMP_DIR}
