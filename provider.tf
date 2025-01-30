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
