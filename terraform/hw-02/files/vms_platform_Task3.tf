##########
### VM WEB
##########

variable "vm_web_subnet_name" {
  type        = string
  default     = "develop-web"
  description = "VPC subnet name"
}

variable "vm_web_default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vm_web_default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

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

##########
### VM DB
##########

variable "vm_db_subnet_name" {
  type        = string
  default     = "develop-db"
  description = "VPC subnet name"
}

variable "vm_db_default_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vm_db_default_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "OS family"
}

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "vm name"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "vm platform"
}

variable "vm_db_cores" {
  type        = number
  default     = "2"
  description = "vm core count"
}

variable "vm_db_memory" {
  type        = number
  default     = "2"
  description = "vm ram size"
}

variable "vm_db_core_fraction" {
  type        = number
  default     = "20"
  description = "vm cores availability"
}

variable "vm_db_preemptible" {
  type        = bool
  default     = "true"
  description = "allow preemptible"
}

variable "vm_db_nat" {
  type        = bool
  default     = "false"
  description = "allow nat"
}

variable "vm_db_serial-port-enable" {
  type        = number
  description = "allow serial console"
}

variable "vm_db_usrname" {
  type        = string
  description = "root user for vm"
}
