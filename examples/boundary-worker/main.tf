module "boundary_worker" {
  source = "../../"

  # --- Common --- #
  friendly_name_prefix = var.friendly_name_prefix
  common_tags          = var.common_tags

  # --- Networking --- #
  create_vpc           = var.create_vpc
  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  create_vm                 = var.create_vm
  vm_ec2_keypair_name       = var.vm_ec2_keypair_name
  vm_cidr_allow_ingress_ssh = var.vm_cidr_allow_ingress_ssh

  create_ec2_ssh_keypair = var.create_ec2_ssh_keypair
  ec2_ssh_keypair_name   = var.ec2_ssh_keypair_name
  ec2_ssh_public_key     = var.ec2_ssh_public_key
}
