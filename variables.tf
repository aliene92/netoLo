###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "vm_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_os_family" {
  type    = string
  default = "ubuntu-2204-lts"
}

variable "vm_user" {
  type    = string
  default = "ubuntu"
}

variable "nat" {
  type    = bool
  default = true
}

###vm web vars

variable "vm_web_count" {
  type    = number
  default = "2"
}

variable "vm_web_name_prefix" {
  type    = string
  default = "web"
}

variable "vm_web_resources" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
    disk_volume   = number
    disk_type     = string
  })

  default = {
    cores         = 2
    memory        = 1
    core_fraction = 5
    disk_volume   = 8
    disk_type     = "network-hdd"
  }
}

###vm db vars

variable "each_vm" {
  type = list(object({ vm_name = string, cpu = number, ram = number, disk_volume = number, core_fraction = number, disk_type = string }))

  default = [
    {
      vm_name       = "main"
      cpu           = 2
      ram           = 1
      disk_volume   = 8
      core_fraction = 5
      disk_type     = "network-hdd"
    },
    {
      vm_name       = "replica"
      cpu           = 4
      ram           = 2
      disk_volume   = 10
      core_fraction = 20
      disk_type     = "network-hdd"
    }
  ]
}

####vm storage vars

variable "storage_disk_count" {
  type    = number
  default = "3"
}

variable "storage_disk_size" {
  type    = number
  default = "1"
}

variable "storage_disk_type" {
  type    = string
  default = "network-hdd"
}

variable "storage_vm_name" {
  type    = string
  default = "storage"
}

variable "storage_vm_resources" {
  type = object({
    cpu           = number
    ram           = number
    core_fraction = number
    disk_volume   = number
    disk_type     = string
  })

  default = {
    cpu           = 2
    ram           = 1
    core_fraction = 5
    disk_volume   = 8
    disk_type     = "network-hdd"
  }
}