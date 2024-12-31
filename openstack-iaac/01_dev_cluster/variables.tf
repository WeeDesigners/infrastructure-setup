variable "kube_worker_count" {
  type        = number
  description = "Number of Virtualn Machines that will act as Kubernetes nodes"
  default     = 4
}

variable "cluster_name" {
    type = string
    description = "Name of the kubernetes cluster"
    default = "dev"
}

variable "ssh_access_sec_group" {
  type = string
  description = "Name of the security group that will allow ssh access to the machine ( should already be in openstack during apply of this terraform)"
  default = "ssh access"
}

variable "cluster_subnet_cidr" {
  type = string
  description = "Cidr for the created subnet in format x.x.x.x/mask"
  default = "192.168.110.0/24"
}


variable "subnet_first_ip" {
  type = string
  description = "First possible ip address to allocate"
  default = "192.168.110.10"
}

variable "subnet_last_ip" {
  type = string
  description = "Last possible ip address to allocate"
  default = "192.168.110.254"
}

variable "kube_master_ip" {
  type = string
  description = "IP for kubernetes master"
  default = "192.168.110.9"
}
