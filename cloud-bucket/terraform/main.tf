terraform {
  required_version = ">= 0.12"
}
provider "google" {
  project     = var.gcp_project
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region
}

provider "google-beta" {
  project     = var.gcp_project_id
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region
}

resource "google_storage_bucket" "sheria-dev" {
  name          = "sheria-dev"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true
}