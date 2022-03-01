
# below block you might want to move to a file called versions.tf
terraform {
  required_version = ">1.0"
  required_providers {
    aws = {
      version = "~>3.6"
    }
  }
}


# you might want to move the block below to a file called aws_provider.tf
provider "aws" {
  region     = var.region
  access_key = var.awsstuff.aws_access_key_id
  secret_key = var.awsstuff.aws_secret_key
}


#  Get VPC ID of ACI built VPC on AWS:

data "aws_vpcs" "vpc_id" {
  tags = {
    AciPolicyDnTag = "*-aciAwsBrownfieldPO*" # adding filter for "uni/tn-sm-terraform-T1/ctxprofile-vrf1-us-east-1"
  }
}


# Set a variable for vpcid value obtained
locals {
  vpcid = element(tolist(data.aws_vpcs.vpc_id.ids), 0)
}



# get subnet IDs:

#  Get the full map for subnet IDs
data "aws_subnet_ids" "example" {
  vpc_id = local.vpcid
}


# set variables for subnetIDs obtained.  Note we have to use type conversion "tolist" and then extract elements from the list
locals {
  subnetid1 = element(tolist(data.aws_subnet_ids.example.ids), 0)
  subnetid2 = element(tolist(data.aws_subnet_ids.example.ids), 1)
  subnetid3 = element(tolist(data.aws_subnet_ids.example.ids), 2)
}




# Upload public ssh key to AWS
##  Notice that this will upload my public key to AWS and use it for the EC2s.  This way, I an login with my private keys.
##  so, first do:   cp ~/.ssh/id_rsa.pub   ./.certs

resource "aws_key_pair" "loginkey" {
  key_name = try("login-key-3") #  using function try here.  If key is already present don't mess with it
  #public_key = file("${path.module}/.certs/id_rsa.pub")  # #  path.module is in relation to the current directory, in case you want to put your id_rsa.pub in ./.certs folder
  public_key = file("~/.ssh/id_rsa.pub")
}



#
## spin up the aws instances.  Note we are using count.index to spin up multiple ec2s as required

data "aws_ami" "std_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}




resource "aws_instance" "sm-terraform1-ec2" {
  ami                         = data.aws_ami.std_ami.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnetid2
  associate_public_ip_address = true
  key_name                    = aws_key_pair.loginkey.key_name
  count                       = var.num_inst
  tags = {
    Name = "ec2-${count.index}-ACI" # first instance will be ec2-0, then ec2-1 etc, etc
  }
}



/**
  Install Apache
  Note we are using triggers here to force the provisioners to run everytime "terraform apply" is used.   
  Normal behavior for provisioner is to run only during first run
  You may or maynot want to use triggers
**/

resource "null_resource" "update" {
  depends_on = [aws_instance.sm-terraform1-ec2]
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 30" # buy a little time to make sure ec2 is reachable
  }
}

# install httpd on all the EC2 instances.  We are using count.index to make sure all EC2s are configured
resource "null_resource" "apache2" {
  depends_on = [null_resource.update]
  count      = var.num_inst
  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd  -y",
      "echo Hello world from $(hostname), private ip = $(hostname -i) > index.html",
      "sudo mv index.html /var/www/html/index.html",
      "sudo service httpd start",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user" # this is the inbuilt ec2 user name for the used ami
      private_key = file("~/.ssh/id_rsa")
      host        = aws_instance.sm-terraform1-ec2[count.index].public_ip
    }
  }
}

# Outputs:   (could put in separate file like output.tf also)

## show vpc_id
output "vpc_id" {
  #value = data.aws_vpcs.vpc_id.ids
  value = element(tolist(data.aws_vpcs.vpc_id.ids), 0)
}
## show subnet IDs
output "subnetid1" {
  value = local.subnetid1
}

output "subnetid2" {
  value = local.subnetid2
}


output "subnetid3" {
  value = local.subnetid3
}

## Show Public IPs
output "publicIP" {

  value = {
    for instance in aws_instance.sm-terraform1-ec2 :
    instance.id => instance.public_ip
  }
}

