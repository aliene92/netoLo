resource "yandex_compute_instance" "web" {
  count = var.vm_web_count

  name        = local.vm_web_names[count.index]
  hostname    = local.vm_web_names[count.index]
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vm_web_resources.disk_volume
      type     = var.vm_web_resources.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = var.nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.metadata

  scheduling_policy {
    preemptible = true
  }

  depends_on = [
    yandex_compute_instance.db
  ]
}