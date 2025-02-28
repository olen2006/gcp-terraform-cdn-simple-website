
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string

}
variable "gcp_region" {
  description = "GCP Region"
  type        = string
}
variable "gcp_svc_key" {
  description = "GCP Service Account Key"
  type        = string
}


variable "env" {
  description = "Environment"
  type        = string
}
variable "subdomain_name" {
  description = "Subdomain Name"
  type        = string

}