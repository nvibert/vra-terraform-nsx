variable "host" {
  description = "VMC NSX-T REVERSE PROXY URL"
}

variable "vmc_token" {
  description = "VMC Token"
}

variable "Subnet12" {
  default = "12.12.12.0/24"
}

variable "Subnet12gw" {
  default = "12.12.12.1/24"
}

variable "Subnet12dhcp" {
  default = "12.12.12.100-12.12.12.200"
}

variable "Subnet13" {
  default = "13.13.13.0/24"
}

variable "Subnet13gw" {
  default = "13.13.13.1/24"
}

variable "Subnet13dhcp" {
  default = "13.13.13.100-13.13.13.200"
}

variable "Subnet14" {
  default = "14.14.14.0/24"
}

variable "Subnet14gw" {
  default = "14.14.14.1/24"
}

variable "Photo_IP" {
  default = "18.133.44.151"
}
