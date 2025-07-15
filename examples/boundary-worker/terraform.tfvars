# --- Common --- #
friendly_name_prefix = "boundary"
common_tags = {
  App         = "boundary-worker"
  Environment = "development"
  Owner       = "platform-engineering"
}

# --- Networking --- #
create_vpc           = true
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.253.0/24", "10.0.254.0/24", "10.0.255.0/24"]

create_vm = true
# if this is null, create_ec2_ssh_keypair must be created. run ssh-keygen manually.
vm_ec2_keypair_name       = null # "hello-sg-keypair" # (or) null # create "hello-sg-keypair via console if you want to use it 
vm_cidr_allow_ingress_ssh = ["0.0.0.0/0"]

# the logic is in bastion.tf line 36.
create_ec2_ssh_keypair = true # if this is false, bastion_ec2_keypair_name must be set. So ec2 keypair must create manually and must already have in AWS.
ec2_ssh_keypair_name   = "sgp-boundary-worker-keypair"
ec2_ssh_public_key     = "<your-ssh-keypair>"