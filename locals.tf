
locals {

  vm_web_names = [
    for index in range(var.vm_web_count) : "${var.vm_web_name_prefix}-${index + 1}"
  ]

  ssh_public_key = file(pathexpand("~/.ssh/id_rsa.pub"))

  metadata = {
    ssh-keys = "${var.vm_user}:${local.ssh_public_key}"
  }

}
