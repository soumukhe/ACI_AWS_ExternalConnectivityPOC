#  Values of variables to override default values defined in variables.tf
#  These are my sample variable values.  Please change based on your requirements.


aws_site_name = "AWS10" # the site name for the AWS site as seen on ND

schema_name   = "SM-Terraform-Tenant-Schema" # give it a name for the schema as you wish
template_name = "shared-template"            # use a template name as you wish
vrf_name      = "vrf1"                       # use a vrf name as you wish
bd_name       = "bd1"                        # use a bd name as you wish
anp_name      = "anp1"                       # use a ANP name as you wish
epg_name      = "epg1"                       # use a EPg name as you wish
region_name   = "us-east-1"                  # Make sure that you choose a region that was enabled in cAPIC initial setup

cidr_ip = "10.140.0.0/16" # CIDR IP as you wish for the VPC to be created in AWS tenant account

subnet1 = "10.140.1.0/24" # subnet should belong to CIDR
zone1   = "us-east-1a"    # az should be the 1st az in the chosen region.

subnet2 = "10.140.2.0/24" # subnet should belong to CIDR
zone2   = "us-east-1b"    # az should be the 2nd az in the chosen region.

subnet3 = "10.140.3.0/24" # subnet should belong to CIDR
zone3   = "us-east-1b"    # az should be the 2nd az in the chosen region.  Only 2 zones are allowed per region currently in cAPIC


epg_selector_value = "10.140.0.0/16" # EPG Selector to ensure proper Security Rules as defined by ACI Contracts

user_association = "soumukhe" #  the user to get associated with the tenant

tgw_name = "TGW" # this is the TGW name that you configured during initial cAPIC setup
