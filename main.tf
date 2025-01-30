resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloud_run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_artifact_registry_repository" "website-tools" {
  repository_id = "websit-tools"
  location      = "us-central1"
  format        = "DOCKER"
}
resource "google_sql_database" "wordpres" {
  name     = var.db_name
  instance = "main-instance"
}

resource "google_sql_user" "wordpress" {
   name     = var.db_user
   instance = "main-instance"
   password = var.db_password
}
resource "google_cloud_run_service" "wordpress-service" {
  name     = "wordpress-service"
  location = "us-central1"
  project  = var.project_id

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/gleaming-mason-444507-t9/websit-tools/custom-wordpress:1.1"
        ports {
          container_port = 80
        }
      }
    }
  }

  traffic {
    latest_revision = true
    percent         = 100
  }
}
data "google_iam_policy" "noauth" {
   binding {
      role = "roles/run.invoker"
      members = [
         "allUsers",
      ]
   }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = google_cloud_run_service.wordpress-service.location
   project     = google_cloud_run_service.wordpress-service.project
   service     = google_cloud_run_service.wordpress-service.name

   policy_data = data.google_iam_policy.noauth.policy_data
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest" # Or a specific version
          port {
            container_port = 80
          }
          env {
            name  = "WORDPRESS_DB_HOST"
            value = "34.58.250.187"
          }
    #      env_from {
    #       secret_ref {
    #          name = kubernetes_secret.mysql_credentials.metadata[0].name
    #        }
    #      }
          env {
            name  = "WORDPRESS_DB_USER"
            value = "wordpress"
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "ilovedevops"
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = "wordpres"
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "mysql_credentials" {
  metadata {
    name      = "mysql-credentials"
  }
  type = "Opaque"
  data = {
     WORDPRESS_DB_PASSWORD = base64encode(var.db_password)    
  }
}

resource "kubernetes_service" "wordpress" {
  metadata {
    name      = "wordpress"

    labels = {
      app = "wordpress"
    }
  }
  spec {
    selector = {
      app = "wordpress"
    }
    port {
      port        = 80
      target_port = 80 
    }
    type = "LoadBalancer"
  }
}
