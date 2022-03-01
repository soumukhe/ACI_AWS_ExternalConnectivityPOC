Please see https://unofficialaciguide.com

Used for POC:  Cisco Cloud ACI Generic External Connectivity.  https://unofficialaciguide.com/

This spins up a VPC, IGW & EC2.  It also installs httpd with a index.html file. ssh keys are imported from local machine you are using.   Security Groups are fully open,  please modify in main.tf as needed.

# Usage:
```
git clone https://github.com/soumukhe/Terraform-aws-physical-dummy.git
cd ACI_AWS_ExternalConnectivityPOC/phyDcOnAwsSimuilated
modify the overfide.tf file and put in your aws credentials for the account where this will be spun up (could be the same ACI tenant account)
modify terraform.tfvars file as needed
terraform init
terraform validate
terraform apply
```
If you needed to change names,IPs hardcoded in main.tf, please vi and change appropriately.
as an example,  to change VPC names and everything associated with string aws-phy-dummy to aws-brownfield you can simply use:
```
sed -i 's/PhySimulated/myNewName/g' main.tf
```
* 📗 Note:
Public IP will spit out on screen after terraform apply.  You could also do terraform refresh followed by terraform output to view it later.
If you needed more than 1 instance, please change the value of num_inst in file terraform.tfvars.  Or comment that out and it will ask you how many instances you want when you do terraform apply
