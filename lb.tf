#https-lb
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${lower(var.lb_prefix)}-https-forwarding-rule"
  port_range            = 443
  ip_address            = google_compute_global_address.external-ip-lb.address
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_https_proxy.default.self_link
}

resource "google_compute_target_https_proxy" "default" {
  name             = "${lower(var.lb_prefix)}-target-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${lower(var.lb_prefix)}-ssl"

  managed {
    domains = var.cert_dns_name
  }
}

resource "google_compute_url_map" "default" {
  name            = "${lower(var.lb_prefix)}-https"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name                            = "${lower(var.lb_prefix)}-backend"
  health_checks                   = [google_compute_health_check.default.id]
  connection_draining_timeout_sec = 30
  enable_cdn                      = var.enable_cdn
  load_balancing_scheme           = "EXTERNAL" #Possible values are EXTERNAL and INTERNAL_SELF_MANAGED.
  port_name                       = "http"
  protocol                        = "HTTP" #Possible values are HTTP, HTTPS, HTTP2, TCP, SSL, and GRPC.

  dynamic "cdn_policy" {
    for_each = var.enable_cdn == true ? var.cdn_policy : {}
    content {
      cache_mode                   = cdn_policy.value["cache_mode"]
      default_ttl                  = cdn_policy.value["default_ttl"]
      client_ttl                   = cdn_policy.value["client_ttl"]
      max_ttl                      = cdn_policy.value["max_ttl"]
      signed_url_cache_max_age_sec = cdn_policy.value["signed_url_cache_max_age_sec"]
    }
  }

  backend {
    group = google_compute_instance_group.webservers.id
  }
}

resource "google_compute_health_check" "default" {
  name                = "${lower(var.lb_prefix)}-hc-tcp-80"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 10

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_instance_group" "webservers" {
  name      = "${lower(var.lb_prefix)}-ig"
  network   = var.network
  zone      = var.zone
  #instances = var.ig_instances

  named_port {
    name = "http"
    port = "80"
  }

}

resource "google_compute_global_address" "external-ip-lb" {
  name = "lb-external"
}

resource "google_compute_firewall" "firewall-lb" {
  network       = var.network
  name          = "allow-lb-health-check"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

}

#http-lb-redirect
resource "google_compute_url_map" "lb-redir" {
  name = "${lower(var.lb_prefix)}-redirect-to-https"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT" #301 redirect
    strip_query            = false
    https_redirect         = true
  }

}

resource "google_compute_target_http_proxy" "http-proxy" {
  name    = "${lower(var.lb_prefix)}-target-proxy-http"
  url_map = google_compute_url_map.lb-redir.id
}

resource "google_compute_global_forwarding_rule" "http-redirect" {
  name                  = "${lower(var.lb_prefix)}-http-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_http_proxy.http-proxy.self_link
  ip_address            = google_compute_global_address.external-ip-lb.address
  port_range            = "80"
}
