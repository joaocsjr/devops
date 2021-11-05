#!/bin/bash

#!/bin/bash
useradd devops 
echo 'password' | passwd --stdin devops

echo 'devops  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
yum install epel-release -y 
yum install bash-completion htop net-tools -y

echo "Post install concluido"