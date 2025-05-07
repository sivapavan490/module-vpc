variable "project_name" {
  # if you give empty variable.Then the value wiil be asked compulsory
}

variable "environment" {
  # if you give empty variable.Then the value wiil be asked compulsory
}

variable "vpc_cidr" {
  # if you give empty variable.Then the value wiil be asked compulsory
}

variable "enable_dns_hostnames" {
    default = true
}

variable "common_tags" {
  type = map
  # default = {}
}