#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
output "vpc_id" {
  value       = module.boundary_worker.vpc_id
  description = "VPC ID."
}

output "private_subnet_ids" {
  value       = module.boundary_worker.private_subnet_ids
  description = "Subnet IDs of private subnets."
}

output "public_subnet_ids" {
  value       = module.boundary_worker.public_subnet_ids
  description = "Subnet IDs of public subnets."
}

output "public_vm_public_dns" {
  value       = module.boundary_worker.public_vm_public_dns
  description = "Public DNS name of vm EC2 instance."
}

output "public_vm_public_ip" {
  value       = module.boundary_worker.public_vm_public_ip
  description = "Public IP of Public vm EC2 instance."
}

output "public_vm_private_ip" {
  value       = module.boundary_worker.public_vm_private_ip
  description = "Private IP of Public vm EC2 instance."
}

output "private_vm_private_dns" {
  value       = module.boundary_worker.private_vm_private_dns
  description = "Private DNS name of Private vm EC2 instance."
}

output "private_vm_private_ip" {
  value       = module.boundary_worker.private_vm_private_ip
  description = "Private IP of Private vm EC2 instance."
}