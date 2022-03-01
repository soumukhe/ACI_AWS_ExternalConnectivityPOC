# this is the file that defines the variables.  The values should be specified in terraform.tfvars
# variable "region" { description = "enter AWS Region " }
variable "access_key" { description = "enter Access Key" }
variable "secret_key" { description = "enter Secret Key" }
variable "instance_type" { default = "t2.micro" }


variable "region" {
  default = "us-east-1"
}

variable "availability_zone1" {
default = "us-east-1a"
}




variable "num_inst" {
  type    = number
  default = 2
}
