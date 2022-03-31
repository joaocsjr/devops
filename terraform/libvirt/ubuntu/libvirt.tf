

locals {
  vms = {
    "k8s-master" = { os_code_name = "focal", network = "nat130", prefixIP = "192.168.130", octetIP = "10", vcpu=2, memoryMB=1024*2 },
    "k8s-worker1" = { os_code_name = "focal", network = "nat131", prefixIP = "192.168.131", octetIP = "10", vcpu=2, memoryMB=1024*2 }
    "k8s-worker2" = { os_code_name = "focal", network = "nat131", prefixIP = "192.168.131", octetIP = "10", vcpu=2, memoryMB=1024*2 }

  }
    # use local instance of dnsmasq listening on local 'l0'
}





# Defining VM Volume
resource "libvirt_volume" "os_image" {
  #for_each = local.vms
  name = "ubuntu.qcow2"
  pool = "default"
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "/opt/stage/ubuntu-20.04.qcow2"
  source = var.templates.ubuntu
 # source = "${var.image["rocky8.5"]}"
  format = "qcow2"
  
 
}


resource "libvirt_volume" "volume" {
 # name           = "volume-${count.index}"
  for_each = local.vms
  name = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.os_image.id

  size = var.disk

}

# get user data info
data "template_file" "user_data" {
    for_each = local.vms

  template = "${file("${path.module}/cloud_init.cfg")}"
   vars = {
    hostname = "${each.key}"
    fqdn = "${each.key}.${var.dns_domain}"
    password = var.password
  

  }

  
}

data "template_file" "network_config" {
  for_each = local.vms
  template = file("${path.module}/network_config.cfg")
    vars = {
    domain = var.dns_domain
  
  }

}


# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = local.vms
  name = "${each.key}-cloudinit.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data = "${data.template_file.user_data[each.key].rendered}"
  network_config = "${data.template_file.network_config[each.key].rendered}"
}






# Define KVM domain to create
resource "libvirt_domain" "domain" {
  for_each = local.vms
  name = "${each.key}"
  memory = each.value.memoryMB
  vcpu = each.value.vcpu
  

  #name   = "var.vhsotnam-${count.index}"
  #memory = "2048"
  #vcpu   = 2
  #count = "${}" 
  
  
  
  network_interface {
   

    network_name = "default"
    wait_for_lease = true
    hostname = "${each.key}.${var.dns_domain}"
   # count = 4
  
  }

 disk { volume_id = libvirt_volume.volume[each.key].id }

 cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id


  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}


output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap( 
                values(libvirt_domain.domain)[*].name,
                values(libvirt_domain.domain)[*].network_interface[*]
                )
}