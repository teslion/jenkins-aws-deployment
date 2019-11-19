########################################################################
#   Terraform requirements   ###########################################
########################################################################
terraform {
  required_version = ">= 0.12"
}
########################################################################
#   Provider   #########################################################
########################################################################
provider "aws" {
  region = var.region
}
########################################################################
#   Master instance   ##################################################
########################################################################
resource "aws_instance" "master_instance" {
  ami                    = lookup(var.ami, var.region)
  instance_type          = var.master_size
  key_name               = aws_key_pair.key.key_name
  availability_zone      = "${var.region}${var.region_zone}"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.subnet.id

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  provisioner "file" {
    source      = "./jenkins_config/setup.groovy"
    destination = "/tmp/setup.groovy"
  }

  provisioner "file" {
    source      = "./jenkins_config/job.xml"
    destination = "/tmp/job.xml"
  }

  provisioner "file" {
    source      = "./jenkins_config/jenkins_cli_config.sh"
    destination = "/tmp/jenkins_config.sh"
  }

  provisioner "file" {
    source      = "./jenkins_config/instance_config.sh"
    destination = "/tmp/instance_config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /tmp/instance_config.sh",
      "sh /tmp/jenkins_config.sh",
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.master_instance.public_ip
    user        = "centos"
    private_key = tls_private_key.key_gen.private_key_pem
  }

  tags = { Name = "${var.project_name}_master" }
}
########################################################################
#   Windows worker instance   ##########################################
########################################################################
resource "aws_instance" "worker_instance" {
  count                  = var.instance_number
  ami                    = lookup(var.worker_ami, var.region)
  instance_type          = var.slave_size
  key_name               = aws_key_pair.key.key_name
  availability_zone      = "${var.region}${var.region_zone}"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.subnet.id

  root_block_device {
    volume_size           = 35
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  tags = { Name = "${var.project_name}_windows_worker" }
}
########################################################################
#   VPC   ##############################################################
########################################################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.subnet_vpc
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = { Name = "${var.project_name}_servers" }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_instances
  availability_zone       = "${var.region}${var.region_zone}"
  map_public_ip_on_launch = "true"

  tags = { Name = "${var.project_name}_subnet" }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = { Name = "${var.project_name}_server_ig" }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = { Name = "${var.project_name}_server_rt" }
}

resource "aws_route_table_association" "rt_rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}
########################################################################
#   Security Group   ###################################################
########################################################################
resource "aws_security_group" "sg" {
  name   = "${var.project_name}_servers"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  ingress {
    description = "RDP access"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  ingress {
    description = "Jenkins GUI access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  ingress {
    description = "Master-Slave communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
########################################################################
#   SSH keys   #########################################################
########################################################################
resource "tls_private_key" "key_gen" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "key" {
  key_name   = var.project_name
  public_key = tls_private_key.key_gen.public_key_openssh
}

resource "local_file" "generated_key" {
  content  = tls_private_key.key_gen.private_key_pem
  filename = "./${var.project_name}.pem"
}

resource "local_file" "login_info" {
  content  = "ssh -i ./${var.project_name}.pem centos@${aws_instance.master_instance.public_ip}"
  filename = "./login.txt"
}
########################################################################
#   Data   #############################################################
########################################################################
data "http" "ip" {
  url = "http://ipv4.icanhazip.com"
}
########################################################################
#   AMI   ##############################################################
########################################################################
variable "ami" {
  type        = map
  description = "CentOS 7 AMI"
  default = {
    us-east-1      = "ami-02eac2c0129f6376b" # N. Virginia
    us-east-2      = "ami-0f2b4fc905b0bd1f1" # Ohio
    us-west-1      = "ami-074e2d6769f445be5" # N. California
    us-west-2      = "ami-01ed306a12b7d1c96" # Oregon
    ap-east-1      = "ami-68e59c19"          # Hong Kong
    ap-south-1     = "ami-02e60be79e78fef21" # Mumbai
    ap-northeast-2 = "ami-06cf2a72dadf92410" # Seoul
    ap-southeast-1 = "ami-0b4dd9d65556cac22" # Singapore
    ap-southeast-2 = "ami-08bd00d7713a39e7d" # Sydney
    ap-northeast-1 = "ami-045f38c93733dd48d" # Tokyo
    ca-central-1   = "ami-033e6106180a626d0" # Canada
    eu-central-1   = "ami-04cf43aca3e6f3de3" # Frankfurt
    eu-west-1      = "ami-0ff760d16d9497662" # Ireland
    eu-west-2      = "ami-0eab3a90fc693af19" # London
    eu-west-3      = "ami-0e1ab783dc9489f34" # Paris
    eu-north-1     = "ami-5ee66f20"          # Stockholm
    me-south-1     = "ami-08529c51dbe004acb" # Bahrain
    sa-east-1      = "ami-0b8d86d4bf91850af" # Sao Paulo
  }
}

variable "worker_ami" {
  type        = map
  description = "Windows server 2019 base AMI"
  default = {
    us-east-1      = "ami-0d4df21ffeb914d61" # N. Virginia
    us-east-2      = "ami-085a6b327e41e6912" # Ohio
    us-west-2      = "ami-0bff712af642c77c9" # Oregon
    ap-east-1      = "ami-0503ce760d2caade4" # Hong Kong
    ap-south-1     = "ami-07b1360b71c3716d8" # Mumbai
    ap-northeast-2 = "ami-0fd7175b57c51b752" # Seoul
    ap-southeast-1 = "ami-00534e787c8349c76" # Singapore
    ap-southeast-2 = "ami-0f307b7625bd712cd" # Sydney
    ap-northeast-1 = "ami-0e48df3801c3e668e" # Tokyo
    ca-central-1   = "ami-0054a87febcce8612" # Canada
    eu-central-1   = "ami-034937fd7f621ba85" # Frankfurt
    eu-west-1      = "ami-0c143cb48fa7c1ec9" # Ireland
    eu-west-2      = "ami-06ea28ca18bb79e3c" # London
    eu-west-3      = "ami-0ba894c68b1681e24" # Paris
    eu-north-1     = "ami-09b605f903aef31cd" # Stockholm
    sa-east-1      = "ami-05b2ce93b518cf8ee" # Sao Paulo
  }
}
########################################################################
#   Output   ###########################################################
########################################################################
output "Jenkins_machine_login_ssh_link" {
  value = "   ssh -i ./${var.project_name}.pem centos@${aws_instance.master_instance.public_ip}"
}
output "Jenkins_server_login_DNS" {
  value = "         http://${aws_instance.master_instance.public_dns}:8080"
}
