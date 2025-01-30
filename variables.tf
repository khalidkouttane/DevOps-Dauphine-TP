variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "db_name" {
  description = "The Name of database"
  type        = string
}

variable "db_user" {
  description = "The name of user"
  type        = string
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive = true
}
