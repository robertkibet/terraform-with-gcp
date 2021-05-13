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

## CREATE A BUCKET IN GCP
# Ref:https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "sheria-dev" {
  name          = "sheria-dev"
  location      = "US"
  force_destroy = false
}


## CREATE AN OBJECT INSIDE OUR BUCKET
#Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
#upload config file first time
resource "google_storage_bucket_object" "configs" {
  name   = "dev-configs"
  source = "./.env" #location to localfile env  stored 
  bucket = "sheria-dev"
}

############
############
############
# USE SECRET MANAGER TO READ CLOUD STORAGE BUCKET
############
############

### add a secret way to read stored object and store it in a file locally

# CREATE SECRET KEY RESOURCE FOR BUCKET NAME AND SPECIFIC FILE IN THE BUCKET

resource "google_secret_manager_secret" "dev_configs_bucket" {
  secret_id = "dev_configs_bucket"

  labels = {
    label = "dev_configs_bucket"
  }

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret" "dev_configs_file" {
  secret_id = "dev_configs_file"

  labels = {
    label = "dev_configs_file"
  }

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}
##USE CREATED RESOURCE AND ADD SOME DATA: A secret that describes our bucket id
#secret for bucket name
resource "google_secret_manager_secret_version" "dev_configs_bucket" {
  secret = google_secret_manager_secret.dev_configs_bucket.id
   #let's match with the name of our cloud bucket
   secret_data = "sheria-dev"
}
#secret for specific filename within the bucket
resource "google_secret_manager_secret_version" "dev_configs_file" {
  secret = google_secret_manager_secret.dev_configs_file.id
   #let's match with the name of our cloud bucket
   secret_data = "dev-configs"
}

##Get some data for bucketname and bucket file of interest resources
data "google_secret_manager_secret_version" "dev_configs_bucket" {
  secret = "dev_configs_bucket"
}
data "google_secret_manager_secret_version" "dev_configs_file" {
  secret = "dev_configs_file"
}

#output values from secret manager, sensitive is true as a requirement for secret manager :P
# output "bucket-name" {
#   description = "bucket name of interest"
#   value = data.google_secret_manager_secret_version.dev_configs_bucket.secret
# }
# output "bucket-file-name" {
#   description = "file in the bucket of interest"
#   value = data.google_secret_manager_secret_version.dev_configs_file.secret
# }


####
####
####
####
#  READ CLOUD STORAGE USING SECRETS AND DOWNLOAD FILE
####
####
data "google_storage_bucket_object" "configs" {
  name = data.google_secret_manager_secret_version.dev_configs_file.secret_data
  bucket = data.google_secret_manager_secret_version.dev_configs_bucket.secret_data
}

data "google_storage_bucket_object_content" "configs" {
  name = data.google_secret_manager_secret_version.dev_configs_file.secret_data
  bucket = data.google_secret_manager_secret_version.dev_configs_bucket.secret_data
}

## read contents from that bucket file and output
output "bucket-content" {
  value = data.google_storage_bucket_object_content.configs.content
}