terraform {
	required_version = ">= 0.14.0"
 	required_providers {
		google = {
			source = "hashicorp/google"
			version = "3.5.0"
		}
	}
}

provider "google" {
	credentials = file(var.gcloud_creds)
	
	project = var.project_name
	
	region  = var.gcloud_region
	zone    = var.gcloud_zone
}

resource "google_compute_address" "static" {
    name = "ipv4-address"
}

resource "google_compute_instance" "web_instance" {
	provider = google
	
	name = "webserver"
	machine_type = "f1-micro"
    
	labels = {
		environment = "prod"
	}
	
	tags = ["prod", "web"]
	
	boot_disk {
		initialize_params {
			image = "debian-cloud/debian-9"
		}
	}

	network_interface {
		# A default network is created for all GCP projects
		network = "default"
		access_config {
            nat_ip = google_compute_address.static.address
   		}
	}
}

resource "google_compute_instance" "mon_instance" {
	provider = google
	
	name = "monitor"
	machine_type = "f1-micro"
    
	labels = {
		environment = "prod"
	}
	
	tags = ["prod", "monitor"]
	
	boot_disk {
		initialize_params {
			image = "debian-cloud/debian-9"
		}
	}

	network_interface {
		# A default network is created for all GCP projects
		network = "default"
		access_config {
   		}
	}
}
