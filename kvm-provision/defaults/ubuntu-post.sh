#!/bin/bash

mkdir -p /home/devops/.ssh
useradd devops  -d /home/devops -s /bin/bash 
echo "devops:password" | chpasswd
echo 'devops  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
apt update -y 
apt install htop net-tools   openssh-server -y 
#configura o netplan para a interface subir no boot qemu-guest-agent
sed -i 's/ens2/enp1s0/' /etc/netplan/01-netcfg.yaml
dhclient

echo "concluida"


