terraform {
    required_version = ">= 1.0.0"
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 4.0.0"
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
    address_type = "EXTERNAL"
}

resource "google_compute_firewall" "default" {
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

resource "google_compute_instance" "webservers" {
    provider = google
    allow_stopping_for_update = true
    
    count = 1
    
    name = "webserver"
    machine_type = var.gcloud_machine_types[1]
    
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
