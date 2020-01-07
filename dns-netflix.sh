#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
dnsnetflix () {
echo "nameserver 34.94.246.97" > /etc/resolv.conf
echo "nameserver 34.95.197.49" >> /etc/resolv.conf

/etc/init.d/ssrmu stop &>/dev/null
/etc/init.d/ssrmu start &>/dev/null

msg -bar2
echo -e "${cor[4]}DNS AGREGADOS CON EXITO"
} 
clear
msg -bar2
echo -e "\033[1;93m     AGREGARDOR DE DNS PERSONALES By @USA1_BOT "
msg -bar2
echo -e "\033[1;39m Esta funcion ara que puedas ver Netflix con tu VPS"
msg -bar2
echo -e "\033[1;91m ¡ Solo seran utiles si registraste tu IP en el BOT !"
echo -e "\033[1;39m En APPS como HTTP Inyector,KPN Rev,APKCUSTOM, etc."
echo -e "\033[1;39m Se deveran agregar en la aplicasion a usar estos DNS."
echo -e "\033[1;36m       DNS USA:    34.94.246.97"
echo -e "\033[1;36m       DNS BRASIL: 34.95.197.49"
echo -e "\033[1;39m En APPS como SS,SSR,V2RAY no es necesario agregarlos."
msg -bar2
read -p " [ s | n ]: " dnsnetflix   
[[ "$dnsnetflix" = "s" || "$dnsnetflix" = "S" ]] && dnsnetflix
msg -bar2