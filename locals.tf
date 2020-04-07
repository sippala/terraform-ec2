variable "aws-account" {
  type = "string"
  default = "beta"
}

locals {
 env_variables = {
        qa  = {
                resource_prefix = "q"
        }
        prod = {
                resource_prefix = "p"
        }

        beta = {
                resource_prefix = "b"
        }

        dev = {
                resource_prefix = "d"
        }
}
  this_env_prefix = "${lookup(local.env_variables["${var.aws-account}"], "resource_prefix")}"
}

output "LOCALS" {
  value = "${local.this_env_prefix}"
}

locals {
 arn_variables = {
        qa  = {
                myrole_arn = "arn:aws:iam::<role>"
        }
        prod = {
                myrole_arn = "arn:aws:iam::<role>"
        }

        beta = {
                myrole_arn = "arn:aws:iam::<role>"
        }

        dev = {
               myrole_arn = "arn:aws:iam::<role>"
        }
  }
  this_role_arn = "${lookup(local.arn_variables["${var.aws-account}"], "myrole_arn")}"
}
