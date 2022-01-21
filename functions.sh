#!/bin/bash

function escape_markdown() {
	echo "${1}" | sed 's#-#\\-#g; s#\.#\\\.#g; s/#/\\%23/g'
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
		| sed 's#&Ntilde;#Ñ#g; s#&ntilde;#ñ#g; s#&ldquo;#"#g; s#&rdquo;#"#g; s#&ndash;#-#g'
}

function format_telegram_ccnorte(){
	echo "*${NAME}*%0A - Data: ${DATE}%0A - Vía: Champion Chip Norte %0A - Máis información: ${URL}"
}

function format_telegram_forestrun(){
	echo "*${NAME}*%0A - Data: ${DATE}%0A - Vía: forestrun %0A - Máis información: ${URL}"
}
