#Compute.tf  https://registry.terraform.io/providers/hashicorp/oci/latest/docs
# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.compartmentid}"
} 
# Output the result
output "show-ads" {
  value = data.oci_identity_availability_domains.ads.availability_domains
} 
resource "oci_core_instance" "ubuntu_instance" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    #Compartment-15Nov that we created in previous exercise 
    compartment_id = "${var.compartmentid}"
    shape = "${var.shape}"
    source_details {
        source_id = "${var.sourceid}"
        source_type = "image"
    }
 
    # Optional - Public Subnet of VNC that has already been created.
    display_name = "${var.hostname}"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = "${var.subnetid}"
    }
    metadata = {
        ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
    }
    preserve_boot_volume = false
}