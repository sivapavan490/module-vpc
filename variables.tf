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

variable "igw_tags"{

    default = {} # it is optional
  
}
# providing condition for must enter 2 cidr blocks only for creating public subnet
variable "public_subnet_cidrs"{
    type = list
    validation {
        condition = length(var.public_subnet_cidrs) == 2
        error_message = " please provide only 2 public_subnet_cidrs only for subnet creation"
    }
  
}

variable "public_subnet_tags" {
  default = {}
}

# providing condition for must enter 2 cidr blocks only for creating 2 private subnet
variable "private_subnet_cidrs"{
    type = list
    validation {
        condition = length(var.private_subnet_cidrs) == 2
        error_message = " please provide only 2 private_subnet_cidrs only for subnet creation"
    }
  
}

variable "private_subnet_tags" {
  default = {}
}

variable "database_subnet_cidrs"{
    type = list
    validation {
        condition = length(var.database_subnet_cidrs) == 2
        error_message = " please provide only 2 database_subnet_cidrs only for subnet creation"
    }
  
}

variable "database_subnet_tags" {
  default = {}
}

variable "public_route_table_tags" {
  default = {}
}

variable "private_route_table_tags" {
  default = {}
}

variable "database_route_table_tags" {
  default = {}
}