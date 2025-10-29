resource "stackit_resourcemanager_project" "fortigate" {
  parent_container_id = var.stackit_organization_id
  name                = "pro-fortigate-${var.environment}"
  owner_email         = var.owner_email
}

resource "stackit_network" "private01" {
  project_id       = stackit_resourcemanager_project.fortigate.project_id
  name             = "nw-private01-${var.environment}"
  ipv4_nameservers = ["9.9.9.9"]
  ipv4_prefix      = "172.29.0.0/24"
  routed           = true
}

resource "stackit_network" "r" {
  project_id       = stackit_resourcemanager_project.fortigate.project_id
  name             = "nw-network-r-${var.environment}"
  ipv4_nameservers = ["9.9.9.9"]
  ipv4_prefix      = "172.30.0.0/24"
  routed           = true
}

resource "stackit_network" "l" {
  project_id       = stackit_resourcemanager_project.fortigate.project_id
  name             = "nw-network-l-${var.environment}"
  ipv4_nameservers = ["9.9.9.9"]
  ipv4_prefix      = "172.31.0.0/24"
  routed           = true
}

resource "stackit_network" "ha_sync" {
  project_id       = stackit_resourcemanager_project.fortigate.project_id
  name             = "nw-ha-sync-${var.environment}"
  ipv4_nameservers = ["9.9.9.9"]
  ipv4_prefix      = "192.168.0.0/24"
  routed           = false
}

resource "stackit_security_group" "web" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  name       = "sg-web-${var.environment}"
  stateful   = true
}

resource "stackit_security_group_rule" "ssh" {
  project_id        = stackit_resourcemanager_project.fortigate.project_id
  security_group_id = stackit_security_group.web.security_group_id
  direction         = "ingress"
  description       = "Allow SSH"
  protocol = {
    name = "tcp"
  }
  port_range = {
    max = 22
    min = 22
  }
}

resource "stackit_image" "alpine" {
  project_id      = stackit_resourcemanager_project.fortigate.project_id
  name            = "img-alpine-${var.environment}"
  disk_format     = "qcow2"
  local_file_path = "alpine.qcow2"
  min_disk_size   = 1
  min_ram         = 128
}

resource "stackit_key_pair" "main" {
  name       = "key-main-${var.environment}"
  public_key = chomp(file(var.public_key_path))
}

# Alpine VMs

resource "stackit_network_interface" "alpine_r" {
  project_id         = stackit_resourcemanager_project.fortigate.project_id
  network_id         = stackit_network.r.network_id
  security_group_ids = [stackit_security_group.web.security_group_id]
  ipv4               = "172.30.0.5"
}

resource "stackit_public_ip" "alpine_r" {
  project_id           = stackit_resourcemanager_project.fortigate.project_id
  network_interface_id = stackit_network_interface.alpine_r.network_interface_id
}

resource "stackit_server" "alpine_r" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  boot_volume = {
    size                  = 1
    source_type           = "image"
    source_id             = stackit_image.alpine.image_id
    performance_class     = "storage_premium_perf0"
    delete_on_termination = true
  }
  name               = "vm-alpine-r-${var.environment}"
  machine_type       = "c2i.1"
  keypair_name       = stackit_key_pair.main.name
  network_interfaces = [stackit_network_interface.alpine_r.network_interface_id]
}

resource "stackit_network_interface" "alpine_l" {
  project_id         = stackit_resourcemanager_project.fortigate.project_id
  network_id         = stackit_network.l.network_id
  security_group_ids = [stackit_security_group.web.security_group_id]
  ipv4               = "172.31.0.5"
}

resource "stackit_public_ip" "alpine_l" {
  project_id           = stackit_resourcemanager_project.fortigate.project_id
  network_interface_id = stackit_network_interface.alpine_l.network_interface_id
}

resource "stackit_server" "alpine_l" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  boot_volume = {
    size                  = 1
    source_type           = "image"
    source_id             = stackit_image.alpine.image_id
    performance_class     = "storage_premium_perf0"
    delete_on_termination = true
  }
  name               = "vm-alpine-l-${var.environment}"
  machine_type       = "c2i.1"
  keypair_name       = stackit_key_pair.main.name
  network_interfaces = [stackit_network_interface.alpine_l.network_interface_id]
}

# FortiGate VMs

resource "stackit_image" "fortios" {
  project_id      = stackit_resourcemanager_project.fortigate.project_id
  name            = "img-fortios-${var.environment}"
  disk_format     = "qcow2"
  local_file_path = "fortios.qcow2"
  min_disk_size   = 1
  min_ram         = 2048
}

resource "stackit_network_interface" "fortigate1_private01" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.private01.network_id
  security   = false
  ipv4       = "172.29.0.3"
}

resource "stackit_network_interface" "fortigate1_network_r" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.r.network_id
  security   = false
  ipv4       = "172.30.0.3"
}

resource "stackit_network_interface" "fortigate1_network_l" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.l.network_id
  security   = false
  ipv4       = "172.31.0.3"
}

resource "stackit_network_interface" "fortigate1_ha_sync" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.ha_sync.network_id
  security   = false
}

resource "stackit_public_ip" "fortigate1" {
  project_id           = stackit_resourcemanager_project.fortigate.project_id
  network_interface_id = stackit_network_interface.fortigate1_private01.network_interface_id
}

resource "stackit_server" "fortigate1" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  boot_volume = {
    size                  = 2
    source_type           = "image"
    source_id             = stackit_image.fortios.image_id
    performance_class     = "storage_premium_perf0"
    delete_on_termination = true
  }
  availability_zone = "eu01-1"
  name              = "ser-fortigate1-${var.environment}"
  machine_type      = "c2i.1"
  keypair_name      = stackit_key_pair.main.name
  network_interfaces = [
    stackit_network_interface.fortigate1_private01.network_interface_id,
    stackit_network_interface.fortigate1_network_r.network_interface_id,
    stackit_network_interface.fortigate1_network_l.network_interface_id,
    stackit_network_interface.fortigate1_ha_sync.network_interface_id,
  ]
  user_data = <<-EOT
  config sys global
    set hostname fortigate1
  end
  config system interface
    edit port1
      set mode static
      set ip 172.29.0.3 255.255.255.0
      set allowaccess http https ssh ping
    next
    edit port2
      set mode static
      set ip 172.30.0.3 255.255.255.0
      set defaultgw disable
      set allowaccess http https ssh ping
    next
    edit port3
      set mode static
      set ip 172.31.0.3 255.255.255.0
      set defaultgw disable
      set allowaccess http https ssh ping
    next
    edit port4
      set mtu-override enable
      set mtu 1400
    next
  end
  config router static
    edit 1
      set gateway 172.29.0.1
      set device "port1"
  end
  config system dns
    set primary 9.9.9.9
  end
  config firewall policy
    edit 1
      set name "Allow port2 to port3"
      set dstintf "port2"
      set srcintf "port3"
      set srcaddr "all"
      set dstaddr "all"
      set action accept
      set schedule "always"
      set service "ALL"
      set nat enable
    next
    edit 2
      set name "Allow port3 to port2"
      set dstintf "port3"
      set srcintf "port2"
      set srcaddr "all"
      set dstaddr "all"
      set action accept
      set schedule "always"
      set service "ALL"
      set nat enable
  end
  EOT

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "stackit_network_interface" "fortigate2_private01" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.private01.network_id
  security   = false
  ipv4       = "172.29.0.4"
}

resource "stackit_network_interface" "fortigate2_network_r" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.r.network_id
  security   = false
  ipv4       = "172.30.0.4"
}

resource "stackit_network_interface" "fortigate2_network_l" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.l.network_id
  security   = false
  ipv4       = "172.31.0.4"
}

resource "stackit_network_interface" "fortigate2_ha_sync" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  network_id = stackit_network.ha_sync.network_id
  security   = false
}

resource "stackit_public_ip" "fortigate2" {
  project_id           = stackit_resourcemanager_project.fortigate.project_id
  network_interface_id = stackit_network_interface.fortigate2_private01.network_interface_id
}

resource "stackit_server" "fortigate2" {
  project_id = stackit_resourcemanager_project.fortigate.project_id
  boot_volume = {
    size                  = 2
    source_type           = "image"
    source_id             = stackit_image.fortios.image_id
    performance_class     = "storage_premium_perf0"
    delete_on_termination = true
  }
  availability_zone = "eu01-2"
  name              = "ser-fortigate2-${var.environment}"
  machine_type      = "c2i.1"
  keypair_name      = stackit_key_pair.main.name
  network_interfaces = [
    stackit_network_interface.fortigate2_private01.network_interface_id,
    stackit_network_interface.fortigate2_network_r.network_interface_id,
    stackit_network_interface.fortigate2_network_l.network_interface_id,
    stackit_network_interface.fortigate2_ha_sync.network_interface_id,
  ]
  user_data = <<-EOT
  config sys global
    set hostname fortigate2
  end
  config system interface
    edit port1
      set mode static
      set ip 172.29.0.4 255.255.255.0
      set allowaccess http https ssh ping
    next
    edit port2
      set mode static
      set ip 172.30.0.4 255.255.255.0
      set defaultgw disable
      set allowaccess http https ssh ping
    next
    edit port3
      set mode static
      set ip 172.31.0.4 255.255.255.0
      set defaultgw disable
      set allowaccess http https ssh ping
    next
    edit port4
      set mtu-override enable
      set mtu 1400
    next
  end
  config router static
    edit 1
      set gateway 172.29.0.1
      set device "port1"
  end
  config system dns
    set primary 9.9.9.9
  end
  config firewall policy
    edit 1
      set name "Allow port2 to port3"
      set dstintf "port2"
      set srcintf "port3"
      set srcaddr "all"
      set dstaddr "all"
      set action accept
      set schedule "always"
      set service "ALL"
      set nat enable
    next
    edit 2
      set name "Allow port3 to port2"
      set dstintf "port3"
      set srcintf "port2"
      set srcaddr "all"
      set dstaddr "all"
      set action accept
      set schedule "always"
      set service "ALL"
      set nat enable
  end
  EOT

  lifecycle {
    ignore_changes = [user_data]
  }
}
