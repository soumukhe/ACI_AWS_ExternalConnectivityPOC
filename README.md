# ACI_AWS_ExternalConnectivityPOC
Code for spinning up full ACI Tenant with EC2s on AWS,  Physical Simulated Environment and EC2s for ACI/AWS External Connectivity POC
Used for POC for ACI/AWS External Connecitivity POC

Please see https://unofficialaciguide.com for full details

# This code has 3 directories
```
aci_tenant                 # Used to spin up an ACI Tenant with 1 VPC, 3 subnets with Transit Gateway Connecitivy to ACI Infra Tenant and other associated objects
awsEC2-onACI_tenant        # Please use the aci_tenant script first.  This script will spin up an ec2 with Apache installed on the ACI Tenant
phyDConAwsSimuilated            #  This script will create a simulated External Data Center environment that you can then integrate with ACI Tenant.  This will help you 
                              to get familiar with the integration without getting distraced by having to setup the basic external Data Center and ACI Tenant.
                              Physical Simulated DC will have 1 VPC with 1 CIDR and 2 subnets.  It will also have IGW so yoyou can ssh in to the EC2 that will be spun up by the plan.  
                              
                             
```


* 📗 Note:  
1) In each directory there are 3 variable files:
   vars.tf,  terraform.tfvars and override.tf.
   Make sure to populate your AWS access-keys and secret keys in the overide.tf file.
   You can also change variable values in terraform.tfvars as you need to.  Feel free to also modify values in vars.tf if you want.
   
  2) When spinning up the ACI Tenant, make sure to first source the environment file "source ./FirstSourceParallelism.env".  This will setup the parallelism=1 env.
     After that you can use your terraform init/fmt/validate/plan/apply/show/refresh/output commands.
     
  3) when spinning up EC2 on the ACI tenant, please first source the environment file: "source ./unset_env_first.env".  This will remove the parallelism env.
  
  
  Please see https://unofficialaciguide.com/  for full step by step guide on ACI/AWS External Connectivity Integration procedure.

