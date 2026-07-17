resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

##########
### VM WEB
##########

resource "yandex_vpc_subnet" "develop" {
  name           = var.vm_web_subnet_name
  zone           = var.vm_web_default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vm_web_default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}

resource "yandex_compute_instance" "platform" {
  name        = local.vm_web_local_name
  platform_id = var.vm_web_platform_id
  zone        = var.vm_web_default_zone
  
  resources {
    cores         = var.vms_resources["web"].cores
    memory        = var.vms_resources["web"].memory
    core_fraction = var.vms_resources["web"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vms_resources["web"].hdd_size
      type     = var.vms_resources["web"].hdd_type
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources["web"].preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vms_resources["web"].nat
  }

metadata = var.metadata
 
}

##########
### VM DB
##########


resource "yandex_vpc_subnet" "develop-db" {
  name           = var.vm_db_subnet_name
  zone           = var.vm_db_default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vm_db_default_cidr
}

data "yandex_compute_image" "ubuntu-db" {
  family = var.vm_db_family
}

resource "yandex_compute_instance" "platform-db" {
  name        = local.vm_db_local_name
  platform_id = var.vm_db_platform_id
  zone        = var.vm_db_default_zone
  
  resources {
    cores         = var.vms_resources["db"].cores
    memory        = var.vms_resources["db"].memory
    core_fraction = var.vms_resources["db"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-db.image_id
      size     = var.vms_resources["db"].hdd_size
      type     = var.vms_resources["db"].hdd_type
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources["db"].preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop-db.id
    nat       = var.vms_resources["db"].nat
  }

 metadata = var.metadata
 
}

##########
###not use
##########

/*
 metadata = {
    serial-port-enable = var.vm_web_serial-port-enable
    ssh-keys           = "${var.vm_web_usrname}:${var.vms_ssh_root_key}"
  }



 metadata = {
    serial-port-enable = var.vm_db_serial-port-enable
    ssh-keys           = "${var.vm_web_usrname}:${var.vms_ssh_root_key}"
  }

*/
