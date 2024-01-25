provider "aws" {
  region = "ap-southeast-1"

  default_tags {
    tags = {
      hashicorp-learn = "checks"
    }
  }
}

locals {
  #unused_limit = timeadd(timestamp(), "-720h")
  #unused_limit = "2023-12-25T00:00:00Z"
  unused_limit = timeadd(plantimestamp(), "-720h")
}

data "aws_iam_access_keys" "example" {
  user = "raymond"
}

output "iam_access_key_output" {
  value = data.aws_iam_access_keys.example
}

locals {
  key_list = tolist(data.aws_iam_access_keys.example.access_keys)
}

locals {
  iam_key_create_date = local.key_list[1].create_date
}

output "iam_access_key_create_date_output" {
  value = local.iam_key_create_date
}

output "iam_access_key_user_output" {
  value = data.aws_iam_access_keys.example.user
}

locals {
  c_data = coalesce(local.iam_key_create_date, local.unused_limit)
}

output "unused_limit_output" {
  value = local.unused_limit
}


output "c_data_output" {
  value = local.c_data
}


check "check_iam_role_unused" {
  assert {
    condition = (
      timecmp(
        coalesce(local.iam_key_create_date, local.unused_limit),
        local.unused_limit,
      ) > 0
    )
    error_message = "error_message here"
  }
}
