data "openstack_networking_router_v2" "project_router" {
  name = "wi-cnmp-router"
}

data "openstack_networking_network_v2" "project_network" {
  name = "project_network"
}

resource "openstack_networking_subnet_v2" "cluster_subnet" {
  name       = "${var.cluster_name}-subnet"
  network_id = data.openstack_networking_network_v2.project_network.id
  cidr       = var.cluster_subnet_cidr
  ip_version = 4

  allocation_pool {
    start = var.subnet_first_ip
    end   = var.subnet_last_ip
  }
}

resource "openstack_networking_router_interface_v2" "management_subnet_interface" {
  router_id = data.openstack_networking_router_v2.project_router.id
  subnet_id = openstack_networking_subnet_v2.cluster_subnet.id
}
