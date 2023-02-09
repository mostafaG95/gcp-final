resource "google_service_account" "gke_sa" {
  account_id   = "default-gke-sa"
  display_name = "sa-gke"
}

resource "google_project_iam_member" "gke_sa_viewer" {
  project = "Mostafa-osama"
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gke_sa.email}"
}


resource "google_container_cluster" "private_cluster" {
  name     = "private-cluster"
  location = "asia-east1" 
  network = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.restricted_subnet.self_link
  remove_default_node_pool = true
  initial_node_count       = 1
  master_authorized_networks_config {
    cidr_blocks {
        cidr_block = "10.0.0.0/24"
        display_name = "management_subnet"
    }
  }

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  network_policy {
    enabled = true
  }

  ip_allocation_policy {
  }


}

resource "google_container_node_pool" "private-cluster-node-pool" {
  name       = "my-node-pool"
  location   = "asia-east1"
  cluster    = google_container_cluster.private_cluster.name
  node_count = 1
 
  node_config {
    preemptible  = true
    machine_type = "e2-micro"
    disk_type    = "pd-standard"
    disk_size_gb = 50
    image_type   = "ubuntu_containerd"
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"

    ]
  }
}