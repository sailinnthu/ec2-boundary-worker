### Generate SSH keypair
```
cd ec2-boundary-worker/examples/boundary-worker
ssh-keygen
```
* Copy your `public_key` and set the variable `ec2_ssh_public_key` in terraform.tfvars
* Run `terraform init` , `terraform plan`, `terraform apply -auto-approve`

* You need to update the boundary worker config accordingly
### Sample Ingress Worker Config
```
disable_mlock = true
hcp_boundary_cluster_id = "<your-boundary-cluster-id>"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}
        
worker {
  public_addr = "<public-ip-or-private-ip>"
  auth_storage_path = "/etc/boundary.d/worker"
  tags {
    type = ["worker0", "public", "ingress", "zone-a", "upstream"]
  }
}
```
### Sample Egress Worker Config
```
disable_mlock = true

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "<your-private-ip>"
  initial_upstreams = ["<upstream-worker-ip>:9202"]
  auth_storage_path = "/etc/boundary.d/worker"
  tags {
    type = ["worker2", "private", "egress", "zone-a", "downstream"]
  }
}
```
### Reload `systemd` and Start `boundary-worker` service
```
sudo systemctl daemon-reload
sudo systemctl enable boundary-worker.service
sudo systemctl start boundary-worker.service
sudo systemctl status boundary-worker.service
```

### Troubleshooting
* If the service fails to start:
```
# Check detailed error logs
sudo journalctl -u boundary-worker.service -l --no-pager

# Check service file syntax
sudo systemd-analyze verify /etc/systemd/system/boundary-worker.service
```

### Registering Boundary Worker with HCPb Controller
* copy `auth_request_token` from `/etc/boundary.d/worker/auth_request_token`
* Go to HCPb UI and Register the Worker
    * Worker public address - `<worker-public-ip-or-private-ip>`
    * Config file path - `/etc/boundary.d/pki-worker.hcl`
    * Worker Tags
        * key - type
        * value - worker0, public, ingress, zone-a, upstream
    * Worker Auth Registration Request

### Verify Worker Registration Successfully
* Run this command `sudo journalctl -u boundary-worker.service -l --no-pager`
