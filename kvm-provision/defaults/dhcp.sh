#!/bin/bash

msg=" Eh preciso informar 3 paremetros: <macaddress> <hostname> <ipadress>"
network="default"
nmac="02:01:00:00:00:"
range="192.168.122."
#name="node"
[[ $# -ne 3 ]] && echo $msg && exit 1


sudo virsh net-update $network  add-last  ip-dhcp-host '<host mac="'$nmac$1'" name="'$name$2'" ip="'$range$3'"/>' --live --config --parent-index 0



#add-host #2>erros_conversao.txt
if [ $? -eq 0 ]
then
  echo "host add com sucesso"
   sudo virsh net-dumpxml  $network | grep host\ mac
else
  echo "Houve uma falha ao add o host"
fi
