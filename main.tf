# main.tf

provider "google" {
  project = "nimble-cortex-428909-b2"
  region  = "europe-central2"  # Choose your preferred region
  credentials = file("/home/misho/limechain/nimble-cortex-428909-b2-3b826e263ed6.json")
}

# resource "google_service_account" "default" {
#   account_id   = "limechain"
#   display_name = "limechain"
# }

resource "google_container_cluster" "primary" {
  name     = "limechain-k8s-test-cluster2"
  location = "europe-central2"  # Replace with your preferred region variable if dynamic
  
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false
}

resource "google_container_node_pool" "default_pool" {
  name       = "default-pool"
  location   = "europe-central2"  # Replace with your preferred region variable if dynamic
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"  # Customize as needed
    service_account = "limechain@nimble-cortex-428909-b2.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Path to your kubeconfig file
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "go-ethereum-dev"
  }

  spec {
    selector {
      match_labels = {
        app = "go-ethereum-dev"
      }
    }

    template {
      metadata {
        labels = {
          app = "go-ethereum-dev"
        }
      }

      spec {
            container {
            image = "ghcr.io/mishomihov/go-ethereum:latest"
            name  = "go-ethereum-dev"

                command = [
                    "geth",
                    "--dev",
                    "--datadir", "/dev-chain",
                    "--http",
                    "--http.api", "personal,eth,web3,net",
                    "--http.addr", "0.0.0.0",
                    "--http.port", "8545",
                    "--password", "/pass.txt"
                ]

                port {
                    container_port = 8545
                }

                env {
                    name  = "GETH_PORT"
                    value = "8545"
                }
            }
        }
    }
  }
}

//Serivce for outside world access is not created for saving time