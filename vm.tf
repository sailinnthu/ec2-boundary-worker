data "aws_ami" "vm" {
  count = var.create_vm && var.create_vpc ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "public_vm" {
  count = var.create_vm && var.create_vpc ? 1 : 0

  ami                         = data.aws_ami.vm[0].id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[count.index].id # launch in public subnet
  vpc_security_group_ids      = [aws_security_group.vm[0].id]
  # key_name                    = var.vm_ec2_keypair_name
  key_name                    = var.vm_ec2_keypair_name != null ? var.vm_ec2_keypair_name : var.ec2_ssh_keypair_name
  associate_public_ip_address = true
  user_data                   = templatefile("${path.module}/templates/vm_user_data.sh.tpl", {})

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(
    { Name = "${var.friendly_name_prefix}-public-vm" },
    var.common_tags
  )
}

resource "aws_instance" "private_vm" {
  count = var.create_vm && var.create_vpc ? 1 : 0

  ami                         = data.aws_ami.vm[0].id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private[count.index].id # launch in private subnet
  vpc_security_group_ids      = [aws_security_group.vm[0].id]
  # key_name                    = var.vm_ec2_keypair_name
  key_name                    = var.vm_ec2_keypair_name != null ? var.vm_ec2_keypair_name : var.ec2_ssh_keypair_name
  associate_public_ip_address = false
  user_data                   = templatefile("${path.module}/templates/vm_user_data.sh.tpl", {})

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(
    { Name = "${var.friendly_name_prefix}-private-vm" },
    var.common_tags
  )
}

resource "aws_security_group" "vm" {
  count = var.create_vm && var.create_vpc ? 1 : 0

  name   = "${var.friendly_name_prefix}-sg-vm-allow"
  vpc_id = aws_vpc.main[0].id

  tags = merge(
    { Name = "${var.friendly_name_prefix}-sg-vm-allow" },
    var.common_tags
  )
}

resource "aws_security_group_rule" "vm_allow_ingress_ssh" {
  count = var.create_vm && var.create_vpc ? 1 : 0

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.vm_cidr_allow_ingress_ssh
  description = "Allow TCP/22 (SSH) from specified CIDR ranges inbound to vm EC2 instance."

  security_group_id = aws_security_group.vm[0].id
}

resource "aws_security_group_rule" "vm_allow_egress_all" {
  count = var.create_vm && var.create_vpc ? 1 : 0

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all traffic egress from vm EC2 instance."

  security_group_id = aws_security_group.vm[0].id
}
