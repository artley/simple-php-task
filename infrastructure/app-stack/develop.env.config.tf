variable profile {
  description = "The profile that will be used"
  type        = string
  default     = "personal"
}

variable region {
  description = "The region that will be used"
  type        = string
  default     = "eu-west-1"
}

variable environment {
  description = "The environment that will be used"
  type        = string
  default     = "develop"
}

provider aws {
  profile = var.profile
  region  = var.region
}

terraform {
  backend s3 {
    bucket         = "simplyanalytics-task1-develop-tfstate"
    dynamodb_table = "simplyanalytics-task1-develop-tfstate"
    region         = "eu-west-1"
    profile        = "personal"
    encrypt        = true

    key = "app-stack/develop/terraform.tfstate"
  }
}