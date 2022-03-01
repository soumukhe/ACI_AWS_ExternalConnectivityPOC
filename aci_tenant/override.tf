#  use this override.tf to put in confidential data

# Note all AWS account related information should be for the AWS account where Tenant will be spun up.
# Please do not put the Infra account related items for these values


#  Populate values based on your AWS values
variable "awsstuff" {
  type = object({
    aws_account_id    = string
    aws_access_key_id = string
    aws_secret_key    = string
  })
  default = {
    aws_account_id    = "Please_Enter_Value"
    aws_access_key_id = "Please_Enter_Value"
    aws_secret_key    = "Please_Enter_Value"
  }
}


#  Populate values based on your ND cofigiration
variable "creds" {
  type = map(any)
  default = {
    username = "Please_Enter_NDO_username"
    password = "Please_Enter_NDO_password"
    url      = "https://Please_Enter_OOB_IP_For_NDO/"
    domain   = "Please_Enter_your_NDO_login_domain_name"   #  if you don't have remote authentication setup, just put the value  local
  }
}
