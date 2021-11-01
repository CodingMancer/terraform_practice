#Same as AWS tell tf the provider this code will be working for
#I really need to figure out how these credentials work in google cloud, I need them to get attached somehow
provider "google" {
  project = "isentropic-keep-330517"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-test-instance"
  machine_type = "e2-micro"
  #This is kind of like the EBS for EC2 instances
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  tags = ["tf"]

  #I haven't figured out if this is for subnet or setting up some form of IGM
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}
#Need to find a way to configure HTTP and HTTPS somewhere
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  allow {
    protocol = "all"
  }

  source_tags = ["tf"]
}

resource "google_compute_network" "default" {
  name = "test-network"
}

#Of course this is our VPC where we can work in a small private corner, just as AWS
#This will be located in the VPC Networks, since it creates a vpc for a majority of the zones. 
#It'll be a long list, so CTRL+F to search
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-test-network"
  auto_create_subnetworks = "true"
}