data "openstack_compute_keypair_v2" "general_access_machine_keypair" {
  name = "general_access_machine_keypair"
}

data "openstack_networking_floatingip_v2" "floatingip_1" {
  address = var.access_machine_floating_ip
}

resource "openstack_networking_port_v2" "access_machine_port" {
  name               = "cluster_1_port"
  network_id         = openstack_networking_network_v2.project_network.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.ssh_access.id]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.management_subnet.id
    ip_address = "192.168.100.10"
  }
}

resource "openstack_networking_floatingip_associate_v2" "access_ip_assoc" {
  floating_ip = data.openstack_networking_floatingip_v2.floatingip_1.address
  port_id     = openstack_networking_port_v2.access_machine_port.id
}

resource "openstack_compute_instance_v2" "general_access_machine" {
  name            = "general_access_machine"
  security_groups = [openstack_networking_secgroup_v2.ssh_access.name]
  image_name      = "ubuntu-server-full-24.04"
  flavor_name     = "c1.small"
  key_pair        = data.openstack_compute_keypair_v2.general_access_machine_keypair.name

  network {
    port = openstack_networking_port_v2.access_machine_port.id
  }
}
