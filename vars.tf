variable "host" {
  description = "VMC NSX-T REVERSE PROXY URL"
}

variable "vmc_token" {
  description = "VMC Token"
}

variable "VMC_subnets" {
  default = {

    Subnet12            = "12.12.12.0/24"
    Subnet12gw          = "12.12.12.1/24"
    Subnet12dhcp        = "12.12.12.100-12.12.12.200"

    Subnet13            = "13.13.13.0/24"
    Subnet13gw          = "13.13.13.1/24"
    Subnet13dhcp        = "13.13.13.100-13.13.13.200"

    Subnet14            = "14.14.14.0/24"
    Subnet14gw          = "14.14.14.1/24"
  }
