###cloud vars


variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

/*
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

*/

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "service_account_key_file" {
  type        = string
  description = "Path to service account key"
}
/*
### New variables

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "OS family"
}

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "vm name"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "vm platform"
}

variable "vm_web_cores" {
  type        = number
  default     = "2"
  description = "vm core count"
}

variable "vm_web_memory" {
  type        = number
  default     = "1"
  description = "vm ram size"
}

variable "vm_web_core_fraction" {
  type        = number
  default     = "5"
  description = "vm cores availability"
}

variable "vm_web_preemptible" {
  type        = bool
  default     = "true"
  description = "allow preemptible"
}

variable "vm_web_nat" {
  type        = bool
  default     = "false"
  description = "allow nat"
}

variable "vm_web_serial-port-enable" {
  type        = number
  description = "allow serial console"
}

variable "vm_web_usrname" {
  type        = string
  description = "root user for vm"
}
*/
###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  description = "ssh-keygen -t ed25519"
}
