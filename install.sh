#!/bin/bash

mkdir -p /home/devops/.ssh
useradd devops  -d /home/devops -s /bin/bash 
#echo "devops:password" | chpasswd
echo 'devops  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

echo "concluida"


