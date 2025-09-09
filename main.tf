resource "stackit_resourcemanager_project" "fortigate" {
  parent_container_id = var.stackit_organization_id
  name                = "pro-fortigate-${var.environment}"
  owner_email         = var.owner_email
}

resource "stackit_network" "fortigate" {
  project_id       = stackit_resourcemanager_project.fortigate.project_id
  name             = "nw-fortigate-${var.environment}"
  ipv4_nameservers = ["9.9.9.9"]
  ipv4_prefix      = "10.0.0.0/24"
  routed           = true
}

resource "stackit_image" "fortios" {
  project_id      = stackit_resourcemanager_project.fortigate.project_id
  name            = "img-fortios-${var.environment}"
  disk_format     = "qcow2"
  local_file_path = "fortios.qcow2"
  min_disk_size   = 1
  min_ram         = 2048
}

resource "stackit_security_group" "fortigate_public" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  name       = "sg-fortigate-public-${var.environment}"
  stateful   = true
}

resource "stackit_security_group" "fortigate_internal" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  name       = "sg-fortigate-internal-${var.environment}"
  stateful   = true
}

resource "stackit_network_interface" "fortigate_public" {
  project_id         = stackit_resourcemanager_project.fortigate.project_id
  network_id         = stackit_network.fortigate.network_id
  security_group_ids = [stackit_security_group.fortigate_public.security_group_id]
}

resource "stackit_network_interface" "fortigate_internal" {
  count = 2

  project_id         = stackit_resourcemanager_project.fortigate.project_id
  network_id         = stackit_network.fortigate.network_id
  security_group_ids = [stackit_security_group.fortigate_internal.security_group_id]
}

resource "stackit_public_ip" "fortigate" {
  project_id           = stackit_resourcemanager_project.fortigate.project_id
  network_interface_id = stackit_network_interface.fortigate_public.network_interface_id
}

resource "stackit_key_pair" "fortigate" {
  name       = "key-fortigate-${var.environment}"
  public_key = chomp(file(var.public_key_path))
}

resource "stackit_volume" "fortios_logs" {
  project_id        = stackit_resourcemanager_project.fortigate.project_id
  name              = "vol-fortios-logs-${var.environment}"
  availability_zone = stackit_server.fortigate.availability_zone
  size              = 32
  performance_class = "storage_premium_perf0"
}

resource "stackit_server_volume_attach" "fortios_logs" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  server_id  = stackit_server.fortigate.server_id
  volume_id  = stackit_volume.fortios_logs.volume_id
}

resource "stackit_server" "fortigate" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  boot_volume = {
    size                  = 2
    source_type           = "image"
    source_id             = stackit_image.fortios.image_id
    performance_class     = "storage_premium_perf0"
    delete_on_termination = true
  }
  availability_zone = "eu01-1"
  name              = "ser-fortigate-${var.environment}"
  machine_type      = "c1a.1d"
  keypair_name      = stackit_key_pair.fortigate.name
  network_interfaces = concat(
    [stackit_network_interface.fortigate_public.network_interface_id],
    stackit_network_interface.fortigate_internal[*].network_interface_id
  )
}
