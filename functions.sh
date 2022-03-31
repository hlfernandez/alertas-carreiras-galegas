#!/bin/bash

function escape_markdown() {
	echo "${1}" | sed 's#-#\\-#g; s#\.#\\\.#g; s/#/\\%23/g; s/(/\\(/g; s/)/\\)/g'
}

function send_telegram() {
	MESSAGE=$(escape_markdown "${1}")
	curl "https://api.telegram.org/bot${BOT_ID_TOKEN}/sendMessage?chat_id=@${CHAT_ID}&text=${MESSAGE}&parse_mode=MarkdownV2"
}

function format_telegram_carreiras_galegas() {
	echo "*${NAME}*%0A - Data: ${DATE}%0A - Lugar: ${PLACE} %0A - Vía: Carreiras Galegas %0A - Máis información: ${LINK}"
}

function process_name() {
	echo $1 \
		| sed 's#&aacute;#á#g; s#&eacute;#é#g; s#&iacute;#í#g; s#&oacute;#ó#g; s#&uacute;#ú#g' \
		| sed 's#&Aacute;#Á#g; s#&Eacute;#É#g; s#&Iacute;#Í#g; s#&Oacute;#Ó#g; s#&Uacute;#Ú#g' \
		| sed 's#&Ntilde;#Ñ#g; s#&ntilde;#ñ#g; s#&ldquo;#"#g; s#&rdquo;#"#g; s#&ndash;#-#g' \
		| sed 's#&ordm;#º#g; s#&amp;#&#g; s#&nbsp;# #g'
}

function format_telegram_ccnorte(){
	echo "*${NAME}*%0A - Data: ${DATE}%0A - Vía: Champion Chip Norte %0A - Máis información: ${URL}"
}

function format_telegram_forestrun(){
	echo "*${NAME}*%0A - Data: ${DATE}%0A - Vía: forestrun %0A - Máis información: ${URL}"
}

function get_month_carreiras_galegas(){
	case "$1" in
	"xaneiro")
		echo "/01/"
		;;
	"febreiro")
		echo "/02/"
		;;
	"marzo")
		echo "/03/"
		;;
	"abril")
		echo "/04/"
		;;
	"maio")
		echo "/05/"
		;;
	"xuño")
		echo "/06/"
		;;
	"xullo")
		echo "/07/"
		;;
	"agosto")
		echo "/08/"
		;;
	"setembro")
		echo "/09/"
		;;
	"outubro")
		echo "/10/"
		;;
	"novembro")
		echo "/11/"
		;;
	"decembro")
		echo "/12/"
		;;
	*)
		echo "NA"
		;;
	esac
}

function get_month_ccnorte(){
	case "$1" in
	"xaneiro")
		echo " ene. "
		;;
	"febreiro")
		echo " feb. "
		;;
	"marzo")
		echo " mar. "
		;;
	"abril")
		echo " abr. "
		;;
	"maio")
		echo " may. "
		;;
	"xuño")
		echo " jun. "
		;;
	"xullo")
		echo " jul. "
		;;
	"agosto")
		echo " ago. "
		;;
	"setembro")
		echo " sep. "
		;;
	"outubro")
		echo " oct. "
		;;
	"novembro")
		echo " nov. "
		;;
	"decembro")
		echo " dic. "
		;;
	*)
		echo "NA"
		;;
	esac
}

function get_month_forestrun(){
	case "$1" in
	"xaneiro")
		echo " Ene "
		;;
	"febreiro")
		echo " Feb "
		;;
	"marzo")
		echo " Mar "
		;;
	"abril")
		echo " Abr "
		;;
	"maio")
		echo " May "
		;;
	"xuño")
		echo " Jun "
		;;
	"xullo")
		echo " Jul "
		;;
	"agosto")
		echo " Ago "
		;;
	"setembro")
		echo " Sep "
		;;
	"outubro")
		echo " Oct "
		;;
	"novembro")
		echo " Nov "
		;;
	"decembro")
		echo " Dic "
		;;
	*)
		echo "NA"
		;;
	esac
}

function show_error() {
	tput setaf 1
	echo -e "$1"
	tput sgr0
	exit 1
}
