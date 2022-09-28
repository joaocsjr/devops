

locals {
  vms = {
    # "rancher" = { os_code_name = "focal", ip = "50", vcpu=2, memoryMB=1024*4 }
    #
   # "lb1" = { os_code_name = "focal", ip = "21", vcpu=2, memoryMB=512 }
   # "lb2" = { os_code_name = "focal", ip = "22", vcpu=2, memoryMB=512 }
    "master" = { os_code_name = "focal", ip = "61", vcpu=2, memoryMB=1024*2 }
   # "master2" = { os_code_name = "focal", ip = "62", vcpu=2, memoryMB=1024*2 }
   # "master3" = { os_code_name = "focal", ip = "63", vcpu=2, memoryMB=1024*2 }
    "worker1" = { os_code_name = "focal", ip = "71", vcpu=2, memoryMB=1024*2 }
    "worker2" = { os_code_name = "focal", ip = "72", vcpu=2, memoryMB=1024*2 }
   #"rancher" = { os_code_name = "focal", ip = "30", vcpu=2, memoryMB=1024*2 }  
   #   "rancher1" = { os_code_name = "focal", ip = "31", vcpu=2, memoryMB=1024*2 }  
  # "rke1" = { os_code_name = "focal", ip = "11", vcpu=2, memoryMB=1024*4 }
  #"nginx" = { os_code_name = "focal", ip = "15", vcpu=2, memoryMB=1024*2 }
  # "rke2" = { os_code_name = "focal", ip = "12", vcpu=2, memoryMB=1024*4 }
  # "rke3" = { os_code_name = "focal", ip = "13", vcpu=2, memoryMB=1024*4 }
   
  }
    # use local instance of dnsmasq listening on local 'l0'
}


# Defining VM Volume
resource "libvirt_volume" "os_image" {
  #for_each = local.vms
  name = "base.qcow2"
  pool = var.diskPool
  source = var.templates.ubuntu
  format = "qcow2"
}


resource "libvirt_volume" "volume" {
  for_each = local.vms
  name = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.os_image.id
  pool = var.diskPool
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
  

  
  
  network_interface {
   

    network_name = "default"
    wait_for_lease = true
    hostname = "${each.key}.${var.dns_domain}"
    addresses  = ["${var.lan}.${each.value.ip}"]
    mac  =  "${var.mac}:${each.value.ip}"
  
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
