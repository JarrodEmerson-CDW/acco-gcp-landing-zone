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
    bucket = "bkt-acco-tf-state-sh"
    prefix = "terraform/bootstrap"
  }
}

provider "google" {
  billing_project = var.cicd_project_id
  user_project_override = true
}

provider "google-beta" {
  billing_project = var.cicd_project_id
  user_project_override = true
}
