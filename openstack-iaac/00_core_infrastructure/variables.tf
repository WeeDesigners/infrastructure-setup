variable "access_machine_floating_ip" {
  type = string
  description = "Floating ip for the access machine"
}

variable "ssh_access_sec_group" {
  type = string
  description = "Name of the security group that will allow ssh access to the machine ( should already be in openstack during apply of this terraform)"
  default = "ssh access"
}
/* variable "project_id" {
  description = "OpenStack project id"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "OpenStack project name"
  type        = string
  default     = ""
}

variable "auth_url" {
  description = "OpenStack authentication url"
  type        = string
  default     = ""
}

variable "username" {
  description = "Openstack username"
  type        = string
  default     = ""
}

variable "password" {
  description = "Openstack password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "region_name" {
  description = "Openstack region"
  type        = string
  default     = "RegionOne"
}

variable "interface" {
  description = "Openstack interface"
  type        = string
  default     = ""
}

variable "api_version" {
  description = "Openstack api version"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Openstack domain name"
  type        = string
  default     = "Default"
}
 */