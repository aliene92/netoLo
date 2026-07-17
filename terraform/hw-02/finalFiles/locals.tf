locals {
  vm_web_local_name = "${var.vm_web_name_pref}-${var.vm_web_name}-${var.vm_web_name_suf}"
  vm_db_local_name  = "${var.vm_db_name_pref}-${var.vm_db_name}-${var.vm_db_name_suf}"
}
