provider "nsxt" {
  host                 = var.host
  vmc_token            = var.vmc_token
  allow_unverified_ssl = true
  enforcement_point    = "vmc-enforcementpoint"
}


/*===========
Get SDDC data
============*/

data "nsxt_policy_tier0_gateway" "vmc" {
  display_name = "vmc"
}

data "nsxt_policy_transport_zone" "TZ" {
  display_name = "vmc-overlay-tz"
}


/*==============
Create segments
===============*/

resource "nsxt_policy_segment" "segment12" {
  display_name        = "segment12"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr              = var.Subnet12gw
    dhcp_ranges       = [var.Subnet12dhcp]
  }
}
resource "nsxt_policy_segment" "segment13" {
  display_name        = "segment13"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr = var.Subnet13gw
    dhcp_ranges = [var.Subnet13dhcp]
  }
}
resource "nsxt_policy_segment" "segment14" {
  display_name        = "segment14"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr = var.Subnet14gw
  }
}

/*===================
Create Network Groups
====================*/


resource "nsxt_policy_group" "group12" {
  display_name = "tf-group12"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet12]
    }
  }
}
resource "nsxt_policy_group" "group13" {
  display_name = "tf-group13"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet13]
    }
  }
}
resource "nsxt_policy_group" "group14" {
  display_name = "tf-group14"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet14]
    }
  }
}

resource "nsxt_policy_group" "name-based-group" {
  display_name = "name-based group"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
      condition {
            key         = "Name"
            member_type = "VirtualMachine"
            operator    = "CONTAINS"
            value       = "photo"
        }
      condition {
            key         = "OSName"
            member_type = "VirtualMachine"
            operator    = "CONTAINS"
            value       = "Ubuntu"
        }
    }
  
  
}

/*==============
Create NAT group
===============*/
resource "nsxt_policy_group" "Photo_Private_IP" {
  display_name = "Photo_Private_IP"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [cidrhost(var.Subnet13, 200)]
    }
  }
}

/*=====================================
Create NAT rule
======================================*/
resource "nsxt_policy_nat_rule" "PhotoApp_NAT" {
  display_name         = "PhotoApp_NAT"
  action               = "DNAT"
  source_networks      = []
  destination_networks = [var.Photo_IP]
  translated_networks  = [cidrhost(var.Subnet13, 200)]
  gateway_path         = "/infra/tier-1s/cgw"

  logging              = false
  firewall_match       = "MATCH_INTERNAL_ADDRESS"
}

/*=====================================
Create Security Group based on NSX Tags
======================================*/
resource "nsxt_policy_group" "Blue_VMs" {
  display_name = "Blue_VMs"
  description = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    condition {
      key = "Tag"
      member_type = "VirtualMachine"
      operator = "EQUALS"
      value = "Blue|NSX_tag"
    }
  }
}

resource "nsxt_policy_group" "Red_VMs" {
  display_name = "Red_VMs"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    condition {
      key = "Tag"
      member_type = "VirtualMachine"
      operator = "EQUALS"
      value = "Red|NSX_tag"
    }
  }
}

/*=====================================
Create DFW rules
======================================*/
resource "nsxt_policy_security_policy" "Terraform_section_1" {
  display_name = "Terraform_section"
  description = "Terraform provisioned Security Policy"
  category = "Application"
  domain = "cgw"
  locked = false
  stateful = true
  tcp_strict = false

  rule {
    display_name = "Micro-segmentation with Terraform"
    source_groups = [
      nsxt_policy_group.name-based-group.path]
    destination_groups = [
      nsxt_policy_group.name-based-group.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
}

resource "nsxt_policy_security_policy" "Colors" {
  display_name = "Colors"
  description = "Terraform provisioned Security Policy"
  category = "Application"
  domain = "cgw"
  locked = false
  stateful = true
  tcp_strict = false

  rule {
    display_name = "Blue2Red"
    source_groups = [
      nsxt_policy_group.Blue_VMs.path]
    destination_groups = [
      nsxt_policy_group.Red_VMs.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
  rule {
    display_name = "Red2Blue"
    source_groups = [
      nsxt_policy_group.Red_VMs.path]
    destination_groups = [
      nsxt_policy_group.Blue_VMs.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
}
