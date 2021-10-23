# **GCP HTTPS LB + HTTP redirect Terraform** #

Deploy HTTPS Load Balancer with Certificate + HTTP redirect in GCP using HashiCorp Terraform.

## The code deploys ##

### General ###

* Global Address
* Firewall

### HTTPS Load Balancer ###

* Global Fowarding Rule
* Target HTTPS Proxy
* Google Managed SSL Certificate
* URL Map
* Backend Service (With decision in CDN Policy)
* Health Check
* Instance Group

### HTTP Load Balancer ###

* Global Fowarding Rule
* Target HTTP Proxy
* URL Map

## **Requirements** ##

Describes requirements for using this module.

### Software ###

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html)>= v0.13.5.
* [Terraform google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)>= v3.87.0.
* [Terraform google-beta provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)>= v3.87.0.

### Service Account ###

* Ensure the you have a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) with sufficient [permissions](https://cloud.google.com/iap/docs/load-balancer-howto#set_up_permissions).


## **Simple Usage** ##

1. Clone the repository:

    ```bash
    git clone https://github.com/taynantofanini/terraform-gcp-external-https-lb.git
    ```

2. Go to module folder

    ```bash
    cd terraform-gcp-external-https-lb
    ```

3. Change variable values in **terraform.tfvars** and backend path in **settings.tf** for your envrionment.

4. Run the following Terraform commands:

    1. Examine configuration files:

        ```bash
        terraform init
        terraform validate
        terraform plan
        ```

    2. Apply the configurations:

        ```bash
        terraform apply
        ```

    3. Confirm configurations:

        ```bash
        terraform output
        terraform show
        ```

    4. To destroy resources:

        ```bash
        terraform plan -destroy
        terraform destroy
        terraform show
        ```

## **Calling this module as a child module** ##

```hcl
module "load-balancer" {
  source = "github.com/taynantofanini/terraform-gcp-external-https-lb"
  #insert the required variables here
}
```

### Required Variables ###

```hcl
gcp_auth_file = "auth/authfile.json" # put your auth file name
project_id    = "your-project-id"
network       = "your-vpc"
zone          = "gcp-zone"
lb_prefix     = "prefix-to-all-resources" #optional
cert_dns_name = ["yourdomain.com.", "www.yourdomain.com.", ]
enable_cdn    = false #decision: true or false

cdn_policy = {

  "Policy" = {
    cache_mode                   = "CACHE_ALL_STATIC" # Possible values are USE_ORIGIN_HEADERS, FORCE_CACHE_ALL, and CACHE_ALL_STATIC
    default_ttl                  = 3600
    client_ttl                   = 7200
    max_ttl                      = 10800
    signed_url_cache_max_age_sec = 7200
  }

}
```

## **Author** ##

* Taynan Tofanini <taynantofanini@gmail.com>
* <https://github.com/taynantofanini/terraform-gcp-external-https-lb>
