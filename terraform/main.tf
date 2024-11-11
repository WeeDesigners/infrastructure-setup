terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.52.1"
    }
  }
}

provider "openstack" {
  user_name        = var.openstack_username
  password         = var.openstack_password
  auth_url         = var.openstack_auth_url
  region           = var.openstack_region
  user_domain_name = var.openstack_user_domain_name
  enable_logging   = true
}

resource "openstack_compute_instance_v2" "access-machine" {
  name            = "access-machine"
  image_name      = "ubuntu-server-full-24.04"
  flavor_name     = "c1.small"
  key_pair        = "access-machine"
  security_groups = ["default"]

  metadata = {
    label = "access"
  }

  network {
    name = "kube_network"
  }
}

resource "openstack_compute_instance_v2" "kube-master-node" {
  name            = "kube-master-node"
  image_name      = "ubuntu-server-full-24.04"
  flavor_name     = "c1.small"
  key_pair        = "kube-master"
  security_groups = ["default"]

  metadata = {
    label = "master-node"
  }

  network {
    name = "kube_network"
  }
}

resource "openstack_compute_instance_v2" "kube-worker-node" {
  count           = 4
  name            = "kube-worker-node-${count.index}"
  image_name      = "ubuntu-server-full-24.04"
  flavor_name     = "c1.small"
  key_pair        = "kube-worker"
  security_groups = ["default"]

  metadata = {
    label = "worker-node"
  }

  network {
    name = "kube_network"
  }
}
