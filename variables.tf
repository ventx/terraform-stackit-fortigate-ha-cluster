variable "environment" {
  type        = string
  description = "The environment name, e. g. test or prod."
  default     = "test"
}

variable "owner_email" {
  type        = string
  description = "Your email address."
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH key public key."
}


variable "stackit_organization_id" {
  type        = string
  description = "Your STACKIT organization ID."
}

variable "stackit_service_account_key_path" {
  type        = string
  description = "Path to your STACKIT service account key JSON file."
}
