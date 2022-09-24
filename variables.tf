variable "aws_region" {
    description = "The AWS region used to create resources"
    default     = "eu-central-1"
}

variable "prefix" {
  type = string
  description = "subfolder for boston-housing regression"
  default = "boston-housing"
}