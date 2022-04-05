
variable "hostname" {
  type = list(string)
  default = ["master","worker1","worker2"]
  description = "Hostname das vms"
}


variable "domain" { default = "fsociety.in" }
variable "memoryMB" { default = 1024*2 }
variable "cpu" { default = 2 }
variable "disk" { default = 107374182400 } # = 100GB
variable "network"{ default = "vlan-100"}
variable "subnet" { default = ["192.168.122.0/24"]}




variable "templates" {
  type = map
  default = {
    "ubunt20" = "01000000-0000-4000-8000-000030080200"
    "centos7"  = "01000000-0000-4000-8000-000050010300"
    "rocky"  = "/opt/stage/Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
  }
}