provider aws {
  profile = var.profile
  region  = var.region
}

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