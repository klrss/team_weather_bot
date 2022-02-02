
/*==========global vars==========*/
variable "aws_region" { }
variable "aws_profile" { }
variable "bucket_name" {}
variable "environment" { }
variable "app_name" { }
variable "image_tag" { }
variable "ecr_repository_url" { }
variable "app_count" { }

variable "taskdef_template" {
  default = "cb_bot.json.tpl"
}


/*==========local vars==========*/
variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}


variable "cidr_block_vpc" {
  default = "10.0.0.0/16"
}
variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "health_check_path" {
  default = "/"
}
locals {
  app_image = format("%s:%s", var.ecr_repository_url, var.image_tag)
}