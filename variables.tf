
variable "vpc_id" {
  type        = string
  description  = "vpc network to attach to"
}

variable "region" {
  type        = string
  description  = "region"
}

variable "availability_zone" {
  type        = string
  description  = "zone"
}

variable "public_cidr_block" {
  type        = string
  description  = "IP block to allocate to new public subnet"
}

variable "private_cidr_block" {
  type        = string
  description  = "IP block to allocate to new private subnet"
}

variable "igw_id" {
  type        = string
  description = "The Internet Gateway to use for subnet routing"
}