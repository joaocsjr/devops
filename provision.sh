#!/bin/bash

ansible-playbook main.yaml -i kvm-provision/inventory 

echo "limpando arquivos de inventario"

sed -i '6,20d' vm-configure/inventory
#sudo sed -e '3,20d;22d' /etc/hosts > /dev/nul
echo "aguardando bootstrap da vm..."
sleep 180
bash ip.sh


#bash kvm/ip.sh
ansible-playbook vm-configure/main.yaml -i vm-configure/inventory 


echo "vms em execucao.."
sudo virsh list 


# ### copiar como root
#ansible all -m authorized_key -a "user=devops state=present key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtti5i5/Pj34Y5QdmvGEfeqiRskmUw4t/eZYnY2BFb/Jut9CCAv9KR4cZ8W7gL729cha6MxUf829/0RXie0+JylCGF/qas4jfeRf4Z0jRqrSnDDf5yBThIotQNf529NTsg0ykfPAzx3qTvgjEnxluCkGrwDaohzusVwOAcIvaceDY8Pj0TnzL6FcEsqyUJGIbZJ+RnIN79bslYMh8TD0t+UTpXwBCzk8wkC7wmnOOGaxzE8QnPsCTjEw48HERTXIQP+SPFSoU+mHfSqNyM9rTr7RI71leKJcorfs2tuDHghhiVHME2nZSR3dJ7w/G8svpsW9tUWc+LyCirYbL92dv1kLWu0vCywYXrs6ikGEkqohTOxZEXqpet5vHWzT4uCvqIwJT9mIVyVqcNwd/vh0gKRzgb1w4ylhK8Z4vzo79cg40vCzaznrjtO2JWGzMxQltWLTH9W4PvNQiSXF5EwciBNXCO1WN7DYYIC3cy91R12fLa/e+X3myW1e5pwh5hB68= jcastro@stella '" -k

### configurando o sudoers
#ansible all -m lineinfile -a "dest=/etc/sudoers state=present line='devops ALL=(ALL) NOPASSWD: ALL'" -k 
