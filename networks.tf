
resource "google_compute_network" "vpc" {
  name = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "management_subnet" {
  name = "management-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region = "asia-east1"
  network = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "restricted_subnet" {
  name = "restricted-subnet"
  ip_cidr_range = "10.1.0.0/24"
  region = "asia-east1"
  network = google_compute_network.vpc.self_link
}

#firewall
resource "google_compute_firewall" "management_subnet_firewall" {
  name    = "management-subnet-firewall"
  network = google_compute_network.vpc.id
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["management-vm"]
  priority = 100
  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
}
#NatGatway 
resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.management_subnet.region
  network = google_compute_network.vpc.self_link
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.management_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}