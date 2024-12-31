data "openstack_networking_router_v2" "project_router" {
  name = "wi-cnmp-router"
}

resource "openstack_networking_network_v2" "project_network" {
  name           = "project_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "management_subnet" {
  name       = "management_subnet"
  network_id = openstack_networking_network_v2.project_network.id
  cidr       = "192.168.100.0/24"
  ip_version = 4

  allocation_pool {
    start = "192.168.100.2"
    end   = "192.168.100.191"
  }
}

resource "openstack_networking_router_interface_v2" "management_subnet_interface" {
  router_id = data.openstack_networking_router_v2.project_router.id
  subnet_id = openstack_networking_subnet_v2.management_subnet.id
}

resource "openstack_networking_secgroup_v2" "ssh_access" {
  name        = var.ssh_access_sec_group
  description = "allow ssh access connections"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.ssh_access.id
  remote_ip_prefix  = "0.0.0.0/0"
}
