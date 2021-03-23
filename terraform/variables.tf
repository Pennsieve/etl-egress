variable "aws_account" {}

variable "environment_name" {}

variable "service_name" {}

variable "tier" {}

variable "version_number" {}

variable "vpc_name" {}

variable "bucket" {
  default = "pennsieve-cc-lambda-functions-use1"
}
