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

# CREATE RESOURCES

# Create a secret resource for username
resource "google_secret_manager_secret" "username" {
  provider = google-beta

  secret_id   = "username"

  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
      replicas {
        location = "europe-west4"
      }
    }
  }
}
# Create a secret resource for password
resource "google_secret_manager_secret" "password" {
  provider = google-beta

  secret_id   = "password"

  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
      replicas {
        location = "europe-west4"
      }
    }
  }
}

#ADD DATA TO RESOURCE CREATED 

# Add the secret data for username secret
resource "google_secret_manager_secret_version" "username" {
  secret = google_secret_manager_secret.username.id
  secret_data = "test-bob"
}

# Add the secret data for password secret
resource "google_secret_manager_secret_version" "password" {
  secret = google_secret_manager_secret.password.id
  secret_data = "Sup3rS3cur3P@ssw0rd3"
}

#OUTPUT RESOURCE DATA

# Read the secret data of username from provided resource
output "username" {
  value = google_secret_manager_secret_version.username.secret_data
  sensitive = true
}

# Read the secret data of password
output "password" {
  value = google_secret_manager_secret_version.password.secret_data
  sensitive = true
}
