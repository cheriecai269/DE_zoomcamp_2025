terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.16.0"
    }
  }
}
provider "google" {
  # credentials = ""
  project = "terraform-demo-448018"
  region  = "us-central1"
}


resource "google_storage_bucket" "demo-bucket" {
  name          = "terraform-demo-448018-demo-bucket"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}


resource "google_bigquery_dataset" "demo-dataset" {
  dataset_id                  = "demo_dataset"
}