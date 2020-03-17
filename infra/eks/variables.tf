variable "region" {
  default = "us-west-2"
}

variable "cluster_name" {
  default = "bl-demo-eks"
}

variable "db_name" {
  default = "bl-demo-rds"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::125635003186:user/bl-alpha-3-demo"
      username = "bl-alpha-3-demo"
      groups   = ["system:masters"]
    }
  ]
}
