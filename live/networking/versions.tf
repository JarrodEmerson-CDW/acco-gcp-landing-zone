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
    prefix = "terraform/networking"
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
