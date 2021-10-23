gcp_auth_file = "auth/authfile.json" # put your auth file name
project_id    = "sd-infraestrutura-dev"
network       = "https://compute.googleapis.com/compute/v1/projects/sd-infraestrutura-dev/global/networks/default"
zone          = "us-east1-b"
lb_prefix     = "taubate"
cert_dns_name = ["yourdomain.com.", "www.yourdomain.com.", ]
#ig_instances  = ["532149427606259565"]
ig_instances  = ["https://compute.googleapis.com/compute/v1/projects/sd-infraestrutura-dev/zones/us-central1-a/instances/532149427606259565", ""]
enable_cdn    = false

cdn_policy = {

  "Policy" = {
    cache_mode                   = "CACHE_ALL_STATIC" # Possible values are USE_ORIGIN_HEADERS, FORCE_CACHE_ALL, and CACHE_ALL_STATIC
    default_ttl                  = 3600
    client_ttl                   = 7200
    max_ttl                      = 10800
    signed_url_cache_max_age_sec = 7200
  }

}
