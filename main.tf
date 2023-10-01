
terraform {
    required_version = ">= 1.0.0"
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 4.0"
        }
    }
}

provider "google" {
    credentials = file(var.gcloud_creds)
    
    project = var.project_name
    
    region  = var.gcloud_regions.toronto
    zone    = "${var.gcloud_regions.toronto}-${var.gcloud_zones[0]}"
}

provider "google-beta" {
    credentials = file(var.gcloud_creds)
    
    project = var.project_name
    
    region  = var.gcloud_regions.toronto
    zone    = "${var.gcloud_regions.toronto}-${var.gcloud_zones[0]}"
}

#################################################
# Workload Identity Pool and Provider
#################################################

resource "google_iam_workload_identity_pool" "gh_actions_idpool" {
  provider = google-beta
  
  workload_identity_pool_id = "gh-deployment-idpool"
  display_name = "GH Actions ID Pool"
  description = "An Identity Pool to interface with GitHub Actions"
  disabled = false
}

resource "google_iam_workload_identity_pool_provider" "gh_actions_idpool_prvdr" {
    provider = google-beta
    
    workload_identity_pool_provider_id = "gh-actions-idpool-prvdr"
    display_name = "GH Actions ID Pool Provider"
    description = "Provider for Workload Identity Pool to interface with GitHub Actions"
    workload_identity_pool_id = google_iam_workload_identity_pool.gh_actions_idpool.workload_identity_pool_id
    attribute_mapping = {
        "google.subject" = "assertion.sub"
        "attribute.actor" = "assertion.actor"
        "attribute.repository" = "assertion.repository"
    }
    oidc {
        issuer_uri = "https://token.actions.githubusercontent.com"
    }
    disabled = false
}

#################################################
# Roles/Service Accounts Related
#################################################

resource "google_project_iam_custom_role" "gh_deploy_role" {
    provider = google
    
    role_id = "ghDeployRole"
    title = "GitHub Deployer Role"
    description = "A role to deploy files to compute instances from GitHub Actions"
    permissions = [
        "iam.serviceAccounts.list",
        "iam.serviceAccounts.get",
        "iam.serviceAccounts.actAs",
        "iam.serviceAccounts.getAccessToken",
        "iam.serviceAccounts.getOpenIdToken",
        "resourcemanager.projects.get",
        "compute.instances.get",
        "compute.projects.get",
        "compute.instances.setMetadata"
    ]
}

resource "google_service_account" "gh_deploy_sa" {
    provider = google
    
    account_id   = "gh-deploy"
    display_name = "GitHub Actions Deployer service account"
    description = "Service Account to interface with GitHub Actions"
}

resource "google_service_account_iam_binding" "gh_deploy_bind" {
    provider = google
    
    service_account_id = google_service_account.gh_deploy_sa.name
    role = google_project_iam_custom_role.gh_deploy_role.name
    members = [
        "serviceAccount:${google_service_account.gh_deploy_sa.email}",
        "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gh_actions_idpool.name}/attribute.repository/${var.github_repo_website}"
    ]
}

#################################################
# OS Related
#################################################

data "google_compute_image" "ubuntu" {
    provider = google
    
    family = "ubuntu-minimal-2204-lts"
    project = "ubuntu-os-cloud"
}

#################################################
# Network Related
#################################################

resource "google_compute_address" "static" {
    provider = google
    
    name = "ext-ipv4-address"
    address_type = "EXTERNAL"
}

resource "google_compute_firewall" "default" {
    provider = google
    
    name    = "web-firewall"
    network = "default"

    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports    = ["80", "443", "8080"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["web"]
}

#################################################
# Compute Related
#################################################

resource "google_compute_instance" "webservers" {
    provider = google
    
    deletion_protection = true
    allow_stopping_for_update = true
   desired_status = "RUNNING" # <- change status to RUNNING to prevent deletion when updating
    
    count = 1
    
    name = "webserver"
    machine_type = var.gcloud_machine_types[1]
    
    labels = {
        environment = "prod"
    }
    
    tags = ["prod", "web"]
    
    boot_disk {
		auto_delete = true
        initialize_params {
            image = data.google_compute_image.ubuntu.self_link
        }
    }

    network_interface {
        network = "default"
        access_config {
            nat_ip = google_compute_address.static.address
        }
    }
    
    metadata = {
    	block-project-ssh-keys = true
        ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
    }  
}

/**
  * Generate an ansible inventory
  */
resource "local_file" "gce_inventory" {
    content = templatefile("templates/gce_inventory.tmpl", {
        ip = google_compute_address.static.address,
        ssh_user = var.ssh_user,
        ssh_keyfile = var.ssh_pvt_key_file
    })
    filename = format("%s/%s", abspath(path.root), "inventory/gce_inventory.yaml")
}
