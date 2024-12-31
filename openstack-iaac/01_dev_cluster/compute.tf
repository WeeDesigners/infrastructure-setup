data "openstack_images_image_v2" "ubuntu" {
  name = "ubuntu-server-full-24.04"
}

data "openstack_compute_keypair_v2" "kube_master_keypair" {
  name = "${var.cluster_name}-kube_master"
}

data "openstack_compute_keypair_v2" "kube_worker_keypair" {
  name = "${var.cluster_name}-kube_worker"
}

data "openstack_networking_secgroup_v2" "ssh_access" {
  name = var.ssh_access_sec_group
}

resource "openstack_networking_port_v2" "kube_master_port" {
  name               = "kube_master_port"
  network_id         = data.openstack_networking_network_v2.project_network.id
  admin_state_up     = "true"
  security_group_ids = [data.openstack_networking_secgroup_v2.ssh_access.id]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.cluster_subnet.id
    ip_address = var.kube_master_ip
  }
}

resource "openstack_compute_instance_v2" "kube_master" {
  name            = "${var.cluster_name}-kube_master"
  image_name      = data.openstack_images_image_v2.ubuntu.name
  flavor_name     = "c1.small"
  key_pair        = data.openstack_compute_keypair_v2.kube_master_keypair.name
  security_groups = [data.openstack_networking_secgroup_v2.ssh_access.name]

  metadata = {
    label = "kube-${var.cluster_name}"
  }

  network {
    port = openstack_networking_port_v2.kube_master_port.id
  }
}

resource "openstack_networking_port_v2" "kube_worker_port" {
  name               = "kube_worker_port-${count.index}"
  network_id         = data.openstack_networking_network_v2.project_network.id
  admin_state_up     = "true"
  security_group_ids = [data.openstack_networking_secgroup_v2.ssh_access.id]
  count              = var.kube_worker_count
}

resource "openstack_compute_instance_v2" "kube_worker" {
  depends_on      = [openstack_compute_instance_v2.kube_master]
  name            = "${var.cluster_name}-kube_worker-${count.index}"
  image_name      = data.openstack_images_image_v2.ubuntu.name
  flavor_name     = "c1.small"
  key_pair        = data.openstack_compute_keypair_v2.kube_worker_keypair.name
  security_groups = [data.openstack_networking_secgroup_v2.ssh_access.name]

  metadata = {
    label = "kube-${var.cluster_name}"
  }

  network {
    port = openstack_networking_port_v2.kube_worker_port[count.index].id
  }

  count = var.kube_worker_count
}
