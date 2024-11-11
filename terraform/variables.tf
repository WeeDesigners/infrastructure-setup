variable "openstack_username" {
  description = "OpenStack username"
  type        = string
  sensitive   = true
}

variable "openstack_password" {
  description = "OpenStack password"
  type        = string
  sensitive   = true
}

# variable "create_secgroup_default" {
#   description = "Create the default security group"
#   type        = bool
#   default     = false
# }

# variable "create_demo_network" {
#   description = "Create demo network"
#   type        = bool
#   default     = true
# }

variable "openstack_auth_url" {
  description = "openstack authentication url"
  type        = string
}

variable "openstack_region" {
  description = "openstack region name"
  type        = string
}

variable "openstack_user_domain_name" {
  description = "openstack user domain name"
  type        = string
}
