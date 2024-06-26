// The variables that will be used in the main.tf file in this example. The values can be asigned here, have a default value, specify a type and can have a description. In our case, they're assigned a value in the tfvars file
variable "gcp_project_id" {
  description = ""
  type        = string
  nullable    = false
}

variable "gcp_service_account_key_file_path" {
  description = ""
  type        = string
  nullable    = false
}

variable "gce_instance_name" {
  description = ""
  type        = string
  nullable    = false
}

variable "gce_instance_user" {
  description = ""
  type        = string
  nullable    = false
}

variable "gce_ssh_pub_key_file_path" {
  description = ""
  type        = string
  nullable    = false
}
