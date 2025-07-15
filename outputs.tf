#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
output "vpc_id" {
  value       = try(aws_vpc.main[0].id, null)
  description = "VPC ID."
}

output "private_subnet_ids" {
  value       = try(aws_subnet.private.*.id, null)
  description = "Subnet IDs of private subnets."
}

output "public_subnet_ids" {
  value       = try(aws_subnet.public.*.id, null)
  description = "Subnet IDs of public subnets."
}

output "public_vm_public_dns" {
  value       = try(aws_instance.public_vm[0].public_dns, null)
  description = "Public DNS name of Public vm EC2 instance."
}

output "public_vm_public_ip" {
  value       = try(aws_instance.public_vm[0].public_ip, null)
  description = "Public IP of Public vm EC2 instance."
}

output "public_vm_private_ip" {
  value       = try(aws_instance.public_vm[0].private_ip, null)
  description = "Private IP of Public vm EC2 instance."
}

output "private_vm_private_dns" {
  value       = try(aws_instance.private_vm[0].private_dns, null)
  description = "Private DNS name of vm EC2 instance."
}

output "private_vm_private_ip" {
  value       = try(aws_instance.private_vm[0].private_ip, null)
  description = "Private IP of vm EC2 instance."
}
