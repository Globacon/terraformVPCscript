variable "region" {
  default     = "us-east-1"
  description = "Region to deploy the resources in"
}

variable "organization" {
  default     = "InsuranceCo"
  description = "The organization namespace"
}

variable "service" {
  default     = "API"
  description = "The service namespace"
}

variable "stage" {
  default     = "sandbox"
  description = "The stage of the environment"
}

variable "public_key" {
  description = "The public key used for EC2 instance"
}