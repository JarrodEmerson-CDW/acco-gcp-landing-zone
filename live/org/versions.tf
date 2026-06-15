terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.40"
    }
  }

  backend "gcs" {
    # bucket and prefix are supplied via -backend-config or terraform.tfbackend file
    # bucket = "<state-bucket-from-bootstrap>"
    prefix = "terraform/org"
  }
}

provider "google" {
  billing_project       = var.billing_project
  user_project_override = true
}

provider "google-beta" {
  billing_project       = var.billing_project
  user_project_override = true
}
