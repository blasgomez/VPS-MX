#!/bin/bash
#19/12/2019
clear
msg -bar
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
BadVPN () {
pid_badvpn=$(ps x | grep badvpn | grep -v grep | awk '{print $1}')
if [ "$pid_badvpn" = "" ]; then
    msg -ama "$(fun_trans "ACTIVANDO BADVPN")"
    msg -bar
    if [[ ! -e /bin/badvpn-udpgw ]]; then
    wget -O /bin/badvpn-udpgw https://www.dropbox.com/s/nxf5s1lffmbikwq/badvpn-udpgw &>/dev/null
    chmod 777 /bin/badvpn-udpgw
    fi
    screen -dmS screen /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
	echo 'sudo screen -dmS screen /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10' >> /bin/autobadvpn 
    [[ "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -verd "ACTIVADO CON EXITO" || msg -ama "$(fun_trans "Fallo")"
else
    msg -ama "$(fun_trans "DESACTIVANDO BADVPN")"
	rm -rf /bin/autobadvpn
    echo '#!/bin/bash' > /bin/autobadvpn
    chmod +x /bin/autobadvpn
    msg -bar
    kill -9 $(ps x | grep badvpn | grep -v grep | awk '{print $1'}) > /dev/null 2>&1
    killall badvpn-udpgw > /dev/null 2>&1
    [[ ! "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ne "DESACTIVADO CON EXITO \n"
    unset pid_badvpn
    fi
unset pid_badvpn
}
TCPspeed () {
if [[ `grep -c "^#ADM" /etc/sysctl.conf` -eq 0 ]]; then
#INSTALA
msg -ama "$(fun_trans "TCP Speed No Activado, Desea Activar Ahora")?"
msg -bar
while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
read -p " [S/N]: " -e -i s resposta
tput cuu1 && tput dl1
done
[[ "$resposta" = @(s|S|y|Y) ]] && {
echo "#ADM" >> /etc/sysctl.conf
echo "net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf > /dev/null 2>&1
msg -ama "$(fun_trans "TCP Activo Con Exito")!"
} || msg -ama "$(fun_trans "Cancelado")!"
 else
#REMOVE
msg -ama "$(fun_trans "TCP Speed ya esta activado, desea detener ahora")?"
msg -bar
while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
read -p " [S/N]: " -e -i s resposta
tput cuu1 && tput dl1
done
[[ "$resposta" = @(s|S|y|Y) ]] && {
grep -v "^#ADM
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" /etc/sysctl.conf > /tmp/syscl && mv -f /tmp/syscl /etc/sysctl.conf
sysctl -p /etc/sysctl.conf > /dev/null 2>&1
msg -ama "$(fun_trans "TCP Parado Con Exito")!"
} || msg -ama "$(fun_trans "Cancelado")!"
fi
}
SquidCACHE () {
msg -ama "$(fun_trans "Squid Cache, Aplica cache en Squid")"
msg -ama "$(fun_trans "Mejora la velocidad del squid")"
msg -bar
if [ -e /etc/squid/squid.conf ]; then
squid_var="/etc/squid/squid.conf"
elif [ -e /etc/squid3/squid.conf ]; then
squid_var="/etc/squid3/squid.conf"
else
msg -ama "$(fun_trans "Su sistema no tiene un squid")!" && return 1
fi
teste_cache="#CACHE DO SQUID"
if [[ `grep -c "^$teste_cache" $squid_var` -gt 0 ]]; then
  [[ -e ${squid_var}.bakk ]] && {
  msg -ama "$(fun_trans "Cache squid identificado, eliminando")!"
  mv -f ${squid_var}.bakk $squid_var
  msg -ama "$(fun_trans "Cache squid Removido")!"
  service squid restart > /dev/null 2>&1 &
  service squid3 restart > /dev/null 2>&1 &
  return 0
  }
fi
msg -ama "$(fun_trans "Aplicando Cache Squid")!"
msg -bar
_tmp="#CACHE DO SQUID\ncache_mem 200 MB\nmaximum_object_size_in_memory 32 KB\nmaximum_object_size 1024 MB\nminimum_object_size 0 KB\ncache_swap_low 90\ncache_swap_high 95"
[[ "$squid_var" = "/etc/squid/squid.conf" ]] && _tmp+="\ncache_dir ufs /var/spool/squid 100 16 256\naccess_log /var/log/squid/access.log squid" || _tmp+="\ncache_dir ufs /var/spool/squid3 100 16 256\naccess_log /var/log/squid3/access.log squid"
while read s_squid; do
[[ "$s_squid" != "cache deny all" ]] && _tmp+="\n${s_squid}"
done < $squid_var
cp ${squid_var} ${squid_var}.bakk
echo -e "${_tmp}" > $squid_var
msg -ama "$(fun_trans "Cache Aplicado con Exito")!"
service squid restart > /dev/null 2>&1 &
service squid3 restart > /dev/null 2>&1 &
}
timemx () {
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/America/Merida /etc/localtime
echo -e " $(fun_trans "FECHA LOCAL MX APLICADA!")"
}
resetiptables () {
echo -e "Reiniciando Ipetables espere"
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -t raw -F && iptables -t raw -X && iptables -t security -F && iptables -t security -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT
echo -e "iptables reiniciadas con exito"
}
on="\033[1;32m[ON]" && off="\033[1;31m[OFF]"
[[ $(ps x | grep badvpn | grep -v grep | awk '{print $1}') ]] && badvpn=$on || badvpn=$off
[[ `grep -c "^#ADM" /etc/sysctl.conf` -eq 0 ]] && tcp=$off || tcp=$on
if [ -e /etc/squid/squid.conf ]; then
[[ `grep -c "^#CACHE DO SQUID" /etc/squid/squid.conf` -gt 0 ]] && squid=$on || squid=$off
elif [ -e /etc/squid3/squid.conf ]; then
[[ `grep -c "^#CACHE DO SQUID" /etc/squid3/squid.conf` -gt 0 ]] && squid=$on || squid=$off
fi
msg -ama "$(fun_trans "MENU DE UTILITARIOS")"
msg -bar
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "BADVPN") $badvpn"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "TCP-SPEED") $tcp"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "CACHE PARA SQUID") $squid"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "APLICAR TIME LOCAL MX")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "RESET IPTABLES")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-5]) ]]; do
read -p "[0-5]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
1)BadVPN;;
2)TCPspeed;;
3)SquidCACHE;;
4)timemx;;
5)resetiptables;;
0)exit;;
esac
msg -bar