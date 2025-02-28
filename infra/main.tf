# Bucket to store website
resource "random_id" "bucket_prefix" {
  byte_length = 8
}
resource "google_storage_bucket" "website" {
  name     = "${random_id.bucket_prefix.hex}-${var.env}-website"
  location = var.gcp_region
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Make new object public 
# Make bucket public by granting allUsers storage.objectViewer access
resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Upload index.html to the bucket
resource "google_storage_bucket_object" "statis_site_src" {
  name   = "index.html"
  bucket = google_storage_bucket.website.name
  source = "../website/index.html"
}

resource "google_storage_bucket_object" "statis_site_src_404" {
  name   = "404.html"
  bucket = google_storage_bucket.website.name
  source = "../website/404.html"
}

###################################################
# Reserving a static external IP address
resource "google_compute_global_address" "website_ip" {
  name = "lb-${var.env}-website-ip"
}

# created manually in GCP console, we just fetch
data "google_dns_managed_zone" "dns_zone" {
  name = "terraform-gcp"
}

resource "google_dns_record_set" "website" {
  name         = data.google_dns_managed_zone.dns_zone.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = [google_compute_global_address.website_ip.address]
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "website_backend" {
  name        = "website-bucket"
  bucket_name = google_storage_bucket.website.name
  description = "Contains files needed for website"
  enable_cdn  = true # disable to invalidate cache
}
# Create HTTPS cerrtificate
resource "google_compute_managed_ssl_certificate" "website_cert" {
  name        = "website-ssl-cert"
  description = "Managed SSL certificate for website"
  managed {
    domains = [google_dns_record_set.website.name]
  }
}

# URL Map for HTTP → HTTPS Redirect
resource "google_compute_url_map" "http_redirect_map" {
  name = "http-redirect-map"
  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_url_map" "website_map" {
  name            = "website-map"
  default_service = google_compute_backend_bucket.website_backend.self_link

  host_rule {
    hosts        = [var.subdomain_name]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.website_backend.self_link
  }
}

# GCP HTTP Proxy
resource "google_compute_target_http_proxy" "http_redirect" {
  name    = "website-http-redirect"
  url_map = google_compute_url_map.http_redirect_map.self_link
}
# GCP HTTPS Proxy (main access)
resource "google_compute_target_https_proxy" "website" {
  name             = "website-target-proxy"
  url_map          = google_compute_url_map.website_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.website_cert.self_link]
  ssl_policy       = google_compute_ssl_policy.website_ssl_policy.self_link
  depends_on       = [google_compute_ssl_policy.website_ssl_policy]
}
# HTTP (80) → Redirect to HTTPS (443)
resource "google_compute_global_forwarding_rule" "http_redirect" {
  name                  = "http-to-https-redirect"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_http_proxy.http_redirect.self_link
  port_range            = "80"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.website_ip.address
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "website" {
  name                  = "website-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_https_proxy.website.self_link
  port_range            = "443"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.website_ip.address
}

# Optional: SSL Policy for Stronger Security
resource "google_compute_ssl_policy" "website_ssl_policy" {
  name            = "website-ssl-policy"
  min_tls_version = "TLS_1_2"
  profile         = "MODERN" #or RESTRICTED
}