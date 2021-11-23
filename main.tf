terraform {
    required_version = ">= 0.14.0"
    required_providers {
        google = {
            source = "hashicorp/google"
            version = ">= 4.0.0"
        }
    }
}

provider "google" {
    credentials = file(var.gcloud_creds)
    
    project = var.project_name
    
    region  = var.gcloud_regions.toronto
    zone    = "${var.gcloud_regions.toronto}-${var.gcloud_zones[0]}"
}

data "google_compute_image" "ubuntu" {
    family = "ubuntu-minimal-2110"
    project = "ubuntu-os-cloud"
}

resource "google_compute_address" "static" {
    name = "ext-ipv4-address"
}

resource "google_compute_instance" "webserver_instance" {
    provider = google
    
    count = 1
    
    name = "webserver"
    machine_type = var.gcloud_machine_types[0]
    
    labels = {
        environment = "prod"
    }
    
    tags = ["prod", "web"]
    
    boot_disk {
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
        ssh-keys = "${var.ssh_user}:file(${var.ssh_pub_key_file})"
    }
}

resource "google_compute_firewall" {
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
