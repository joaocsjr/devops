
variable "hostnamee" {
  type = list(string)
  default = ["k8s-master","k8s-worker1","k8s-worker2","k8s-worker3"]
  description = "Hostname das vms"
}


variable "compartmentid" { default = "ocid1.tenancy.oc1..aaaaaaaazfv3x5lryqmru56no3ktve7qh26gipya3kyhufwwyuumxs5yjoda" }
variable "shape" { default = "VM.Standard.E2.1.Micro" }
variable "sourceid" { default = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaakgamg7r5bo55dcplbauqcvk2tbtsol3qtgmoubqdc22u66shmu5a" }
variable "subnetid" { default = "ocid1.subnet.oc1.sa-vinhedo-1.aaaaaaaausdg3g6htfj267hb72f7fqlzk5pc24awpkx5yvfvu5x5czzcqcmq" } 
variable "sshkey"{ default = "~/.ssh/id_rsa.pub"}
variable "hostname"{ default = "ubuntu-server"}




