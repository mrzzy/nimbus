#
# nimbus
# terraform deploy for wasabi storage
# input variables
#

variable "access_key" {
  type        = string
  description = "ID of Access Key used to authenticate with Wasabi"
}


variable "secret_key" {
  type        = string
  description = "Secret Key used to authenticate with Wasabi"
}
