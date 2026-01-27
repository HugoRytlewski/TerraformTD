//Nom de l'application
variable "app_name" {
  type    = string
  default = "server-student"
}

//Region
variable "region" {
  type    = string
  default = "France Central"
}

//Taille de l'instance
variable "instance_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "admin_user" {
  type        = string
  description = "Admin username for the VM"
  default     = "adminuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH Public Key for the VM"
  default     = ""
}



