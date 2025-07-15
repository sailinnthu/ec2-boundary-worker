#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "create_vpc" {
  type        = bool
  description = "Boolean to create a VPC."
  default     = false
}

variable "vpc_name" {
  type        = string
  description = "Name of VPC."
  default     = "vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC."
  default     = null
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR ranges to create in VPC."
  default     = []
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDR ranges to create in VPC."
  default     = []
}

variable "create_vm" {
  type        = bool
  description = "Boolean to create a vm EC2 instance. Only valid when `create_vpc` is `true`."
  default     = false
}

variable "vm_ec2_keypair_name" {
  type        = string
  description = "Existing SSH key pair to use for vm EC2 instance."
  default     = null
}

variable "vm_cidr_allow_ingress_ssh" {
  type        = list(string)
  description = "List of source CIDR ranges to allow inbound to vm on port 22 (SSH)."
  default     = []
}

#------------------------------------------------------------------------------
# EC2 SSH Key Pairs
#------------------------------------------------------------------------------
variable "create_ec2_ssh_keypair" {
  type        = bool
  description = "Boolean to create EC2 SSH key pair. This is separate from the `vm_keypair` input variable."
  default     = false
}

variable "ec2_ssh_keypair_name" {
  type        = string
  description = "Name of EC2 SSH key pair."
  default     = "ec2-keypair"
}

variable "ec2_ssh_public_key" {
  type        = string
  description = "Public key material for EC2 SSH Key Pair."
  default     = null
}