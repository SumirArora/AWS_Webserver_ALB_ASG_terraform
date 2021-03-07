variable "region" {
  default = "ap-south-1"
}
/*
variable "ami_id" {
  type = "map"
  default = "ami-0947d2ba12ee1ff75"
}
*/

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["10.0.30.0/24", "10.0.40.0/24"]
  type        = list
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
  type        = list
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default     = ["ap-south-1a", "ap-south-1b"]
  type        = list
}

#variable key_name {}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
}

variable "ssh_port" {
  default = 22
}