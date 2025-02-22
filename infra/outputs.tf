# Outputs for the GCS Bucket
output "website_bucket_name" {
  description = "The name of the Google Cloud Storage bucket hosting the website."
  value       = google_storage_bucket.website.name
}

output "website_bucket_url" {
  description = "The URL of the website hosted on the GCS bucket."
  value       = "https://${google_storage_bucket.website.name}.storage.googleapis.com"
}

# Outputs for the Static IP Address
output "website_static_ip" {
  description = "The static IP address reserved for the website."
  value       = google_compute_global_address.website_ip.address
}

# Outputs for DNS Configuration
output "website_dns_name" {
  description = "The DNS name of the website."
  value       = "${var.subdomain_name}."
}

output "website_dns_record" {
  description = "The DNS A record pointing to the website's static IP."
  value       = google_dns_record_set.website.rrdatas
}

# Outputs for the CDN Backend
output "website_cdn_backend_name" {
  description = "The name of the CDN backend bucket."
  value       = google_compute_backend_bucket.website_backend.name
}

output "website_cdn_enabled" {
  description = "Whether CDN is enabled for the backend bucket."
  value       = google_compute_backend_bucket.website_backend.enable_cdn
}

# Outputs for SSL Certificate
output "website_ssl_certificate_name" {
  description = "The name of the managed SSL certificate."
  value       = google_compute_managed_ssl_certificate.website_cert.name
}

output "website_ssl_certificate_domains" {
  description = "The domains covered by the SSL certificate."
  value       = google_compute_managed_ssl_certificate.website_cert.managed[0].domains
}

# Outputs for Load Balancer and Proxies
output "website_https_proxy_name" {
  description = "The name of the HTTPS proxy for the website."
  value       = google_compute_target_https_proxy.website.name
}

output "website_http_redirect_proxy_name" {
  description = "The name of the HTTP-to-HTTPS redirect proxy."
  value       = google_compute_target_http_proxy.http_redirect.name
}

# Outputs for Forwarding Rules
output "website_https_forwarding_rule" {
  description = "The name and IP address of the HTTPS forwarding rule."
  value = {
    name = google_compute_global_forwarding_rule.website.name
    ip   = google_compute_global_forwarding_rule.website.ip_address
  }
}

output "website_http_forwarding_rule" {
  description = "The name and IP address of the HTTP forwarding rule."
  value = {
    name = google_compute_global_forwarding_rule.http_redirect.name
    ip   = google_compute_global_forwarding_rule.http_redirect.ip_address
  }
}

# Outputs for SSL Policy
output "website_ssl_policy_name" {
  description = "The name of the SSL policy applied to the HTTPS proxy."
  value       = google_compute_ssl_policy.website_ssl_policy.name
}

output "website_ssl_policy_min_tls_version" {
  description = "The minimum TLS version enforced by the SSL policy."
  value       = google_compute_ssl_policy.website_ssl_policy.min_tls_version
}

# Output for Website URL
output "website_url" {
  description = "The full URL of the website."
  value       = "https://${var.subdomain_name}."
}