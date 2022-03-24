
variable "hostname" {
  type = list(string)
  default = ["node-1","node-2","node-3"]
  description = "Hostname das vms"
}


variable "domain" { default = "fsociety.lab" }
variable "memoryMB" { default = 1024*2 }
variable "cpu" { default = 2 }
variable "disk" { default = 100 * 1024 * 1024 * 1024 } # = 100GB
variable "network"{ default = "vlan-100"}
variable "subnet" { default = ["192.168.100.0/24"]}




variable "templates" {
  type = map
  default = {
    "ubuntu" = "/opt/stage/ubuntu-20.04.qcow2"
    "centos7"  = "01000000-0000-4000-8000-000050010300"
    "rocky"  = "/opt/stage/Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
  }
}



variable "password" { default="linux" }
variable "dns_domain" { default="fsociety.lab"  }
variable "ip_type" { default = "static" }

# kvm standard default network
variable "prefixIP" { default = "192.168.122" }

# kvm disk pool name
variable "diskPool" { default = "default" }

variable "virsh_network_name" { default = "default" }