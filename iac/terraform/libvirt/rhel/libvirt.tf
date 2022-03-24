





# Defining VM Volume
resource "libvirt_volume" "os_image" {
  name = "os-image"
  pool = "default"
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "/opt/stage/ubuntu-20.04.qcow2"
  source = var.templates.rocky
 # source = "${var.image["rocky8.5"]}"
  format = "qcow2"
 
}


resource "libvirt_volume" "volume" {
 # name           = "volume-${count.index}"
  name = "${var.hostname[count.index]}"
  base_volume_id = libvirt_volume.os_image.id
  count = length(var.hostname)
  size = var.disk

}

# get user data info
data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
    vars = {
##    hostname = var.hostname
    domainname = var.domain
  }
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data = "${data.template_file.user_data.rendered}"
}






# Define KVM domain to create
resource "libvirt_domain" "domain" {
  count = length(var.hostname)
  name = var.hostname[count.index]
  memory = var.memoryMB
  vcpu = var.cpu
  

  #name   = "var.vhsotnam-${count.index}"
  #memory = "2048"
  #vcpu   = 2
  #count = "${}" 
  
  
  
  network_interface {
    network_name = "default"
    wait_for_lease = true
   # count = 4
  
  }

  disk {
    volume_id = element(libvirt_volume.volume.*.id, count.index)
  }
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"   


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


output "ips" {

  value = libvirt_domain.domain.*.network_interface.0.addresses
}






output "name" {

  value = libvirt_domain.domain.*.name
}