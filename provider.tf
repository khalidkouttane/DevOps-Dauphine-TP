provider "google" {
  project     = var.project_id
  region      = "us-central1"
}
terraform {
  backend "gcs" {
    bucket = "gleaming-mason-444507-t9-tfstate"
    prefix = "Devops-Dauphine-TP"
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
   name     = "gke-dauphine"
   location = "us-central1-a"
}

provider "kubernetes" {
   host                   = data.google_container_cluster.my_cluster.endpoint
   token                  = data.google_client_config.default.access_token
   cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)
}
