#!/usr/bin/env bash

sudo yum update -y
sudo yum install -y jq net-tools unzip
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

BOUNDARY_URL=$(curl -fsSL "https://api.releases.hashicorp.com/v1/releases/boundary/latest?license_class=enterprise" | jq -r '.builds[] | select(.arch == "amd64" and .os == "linux") | .url')
BOUNDARY_FILENAME=$(basename "$BOUNDARY_URL")
sudo wget -q "$BOUNDARY_URL"
sleep 1
unzip "$BOUNDARY_FILENAME"

# sudo wget -q "$(curl -fsSL "https://api.releases.hashicorp.com/v1/releases/boundary/latest?license_class=enterprise" | jq -r '.builds[] | select(.arch == "amd64" and .os == "linux") | .url')"
# sleep 1
# unzip boundary_0.19.3+ent_linux_amd64.zip
sleep 1
sudo useradd --system --user-group boundary || true
sleep 1

sudo mv boundary /usr/local/bin
cd /usr/local/bin
sudo chown boundary:boundary boundary
cd $HOME
boundary version

# [Install Boundary under systemd](https://developer.hashicorp.com/boundary/docs/install-boundary/systemd)
cd /etc/
sudo mkdir boundary.d
sudo chown boundary:boundary boundary.d
cd boundary.d

# sudo touch pki-worker.hcl
sudo cat > /etc/boundary.d/pki-worker.hcl << 'EOF'
disable_mlock = true
hcp_boundary_cluster_id = "<boundary-cluster-id>"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}
        
worker {
  public_addr = "<your-public-ip-or-private-ip>"
  initial_upstreams = ["10.0.111.109:9202"]
  auth_storage_path = "/etc/boundary.d/worker"
  tags {
    type = ["worker0", "public", "ingress", "zone-a", "upstream"]
  }
}
EOF

sudo mkdir worker
sudo chown boundary:boundary *

# sudo touch /etc/boundary.d/pki-worker.hcl

# systemd for boundary-worker.service
sudo cat > /etc/systemd/system/boundary-worker.service << 'EOF'
[Unit]
Description=boundary worker

[Service]
ExecStart=/usr/local/bin/boundary server -config /etc/boundary.d/pki-worker.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF