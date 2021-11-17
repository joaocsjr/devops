

#sudo virt-builder -v --format qcow2  ubuntu-18.04 -o /var/lib/libvirt/images/vm1.qcow2 --size 30G --hostname vm1 --root-password password:password --run /home/jcastro/devops/kvm/install.sh    --ssh-inject devops:file:/home/jcastro/.ssh/id_rsa.pub 




