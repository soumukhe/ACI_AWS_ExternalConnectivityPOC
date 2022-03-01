
# Note all AWS account related information should be for the AWS account where Tenant will be spun up.  
# Please do not put the Infra account related items for these values


variable "awsstuff" {
  type = map(any)
  default = {
    aws_account_id         = "Please_Enter_Value"
    is_aws_account_trusted = false
    aws_access_key_id      = "Please_Enter_Value"
    aws_secret_key         = "Please_Enter_Value"
  }
}

