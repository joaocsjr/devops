




locals {
  vms = {
    "vm1" = { os_code_name = "focal", network = "kvmnet", prefixIP = "192.168.68", octetIP = "11", vcpu=2, memoryMB=1024*4 }
    "vm2" = { os_code_name = "focal",network = "kvmnet", prefixIP = "192.168.68", octetIP = "12", vcpu=2, memoryMB=1024*2 }
    "vm3" = { os_code_name = "focal",network = "kvmnet", prefixIP = "192.168.68", octetIP = "13", vcpu=2, memoryMB=1024*2 }

    #"k8sw2" = { os_code_name = "focal", ip = "32", vcpu=2, memoryMB=1024*2 }
    #"haproxy13" = { os_code_name = "focal", ip = "13", vcpu=2, memoryMB=1024*2 }
   #"k3pis" = { os_code_name = "focal", ip = "30", vcpu=2, memoryMB=1024*2 }  
    
  }
  networks ={
        "kvmnet" = { mode="bridge", address="192.168.66.0/24", domain="jcastro.lab", dns_forwarder="8.8.8.8"},
        #"kvmnet2" = { mode="bridge", address="192.168.66.0/24", domain="home.lab", dns_forwarder="127.0.0.1"},



  }
    # use local instance of dnsmasq listening on local 'l0'
}
#resource "libvirt_network" "kvm_network" {
#  name = "kvmnet"
#  mode = "bridge"
#  bridge = "br0"
#  autostart = "true"
#}


resource "libvirt_network" "routed" {
  for_each = local.networks
  name = each.key
  # nat|none|route|bridge
  mode = each.value.mode
  addresses = [ each.value.address ]
  bridge = "br0"
  autostart = "true"

}



# Defining VM Volume
resource "libvirt_volume" "os_image" {
  #for_each = local.vms
  name = "base.qcow2"
  pool = var.diskPool
  source = var.templates.ubuntu22
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
    fqdn = "${each.key}.${var.domain}"
    password = var.password
  

  }

  
}

data "template_file" "network_config" {
  for_each = local.vms
  template = file("${path.module}/network_config.cfg")
    vars = {
    #domain = var.dns_domain
    domain = var.domain
    prefixIP = each.value.prefixIP
    octetIP = each.value.octetIP
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
  name = "${each.key}-[${each.value.prefixIP}.${each.value.octetIP}]"
  memory = each.value.memoryMB
  vcpu = each.value.vcpu
  qemu_agent = true

  

  
  
  network_interface {
   

    network_name = "${each.value.network}"
    wait_for_lease = false
    hostname = "${each.key}.${var.domain}"
   # addresses  = ["${each.value.ip}"]
    #mac  =  "${var.mac}:${each.value.ip}"
  
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

output "routed_networks" {
  value = zipmap(
                values(libvirt_domain.domain)[*].name,
                values(libvirt_domain.domain)[*].network_interface[*]
                )
}



output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap( 
                values(libvirt_domain.domain)[*].name,
                values(libvirt_domain.domain)[*].network_interface[*]
                )
}
