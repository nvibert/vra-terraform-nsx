provider "nsxt" {
  host                 = var.host
  vmc_token            = var.vmc_token
  allow_unverified_ssl = true
  version              = "!= 1.1.2"
  enforcement_point    = "vmc-enforcementpoint"
}

resource "nsxt_policy_group" "mygroup2" {
  display_name = "my-policy-group - tags"
  description  = "Created from Terraform by Nico"
  domain       = "cgw"

  criteria {
    condition {
      key = "Tag"
      member_type = "VirtualMachine"
      operator = "EQUALS"
      value = "red"
    }
  }
}

data "nsxt_policy_service" "dns_service" {
  display_name = "DNS"
}
 

resource "nsxt_policy_security_policy" "policy2" {
  domain       = "cgw"
  display_name = "policy2"
  description  = "Terraform provisioned Security Policy"
  category     = "Application"

  rule {
    display_name  = "rule name"
    source_groups = ["${nsxt_policy_group.mygroup2.path}"]
    action        = "DROP"
    services      = ["${nsxt_policy_service.nico-service_l4port2.path}"]
    logged        = true
  }
}

resource "nsxt_policy_security_policy" "policy_existing_service" {
  domain       = "cgw"
  display_name = "policy_using_existing_service"
  description  = "Terraform provisioned Security Policy"
  category     = "Application"

  rule {
    display_name  = "rule name"
    source_groups = ["${nsxt_policy_group.mygroup2.path}"]
    action        = "DROP"
    services      = [data.nsxt_policy_service.dns_service.path]
    logged        = true
  }
}

resource "nsxt_policy_service" "nico-service_l4port2" {
  description  = "L4 ports service provisioned by Terraform"
  display_name = "service-s2"

  l4_port_set_entry {
    display_name      = "TCP82"
    description       = "TCP port 82 entry"
    protocol          = "TCP"
    destination_ports = ["82"]
  }
}
