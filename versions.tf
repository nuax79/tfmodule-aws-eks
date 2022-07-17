terraform {
  required_version = ">= 0.13.5"

  required_providers {
    aws        = ">= 3.33.0"
    local      = ">= 1.4"
    null       = ">= 2.1"
    template   = ">= 2.1"
    random     = ">= 2.1"
    kubernetes = ">= 2.0.0"
  }
}
