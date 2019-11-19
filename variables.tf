########################################################################
#   Variables   ########################################################
########################################################################
variable "instance_number" {
  default     = "0"
  description = "Number of windows slave instances (workers) to be created."
}

variable "region" {
  default     = "eu-central-1"
  description = "AWS region where the instances will be deployed."
}

variable "region_zone" {
  default     = "a"
  description = "AWS zone in the region where the instances will be deployed."
}

variable "project_name" {
  default     = "jenkins"
  description = "Name to give to the servers and all their accompanying infrastructure created."
}

variable "zone_name" {
  default     = "example.com"
  description = "Domain name for the hosting zone to use."
}

variable "master_size" {
  default     = "t2.micro"
  description = "Instance size to boot master server on."
}

variable "slave_size" {
  default     = "t2.medium"
  description = "Instance size to boot slave server on."
}

#If you are creating more than 10 jenkins slaves (workers), change folowing two values acordingly:
variable "subnet_vpc" {
  default     = "192.168.254.0/24"
  description = "Entire CIDR block that VPC is using."
}

variable "subnet_instances" {
  default     = "192.168.254.240/28"
  description = "CIDR block that instances are using."
}
