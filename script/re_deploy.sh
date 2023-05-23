#!/bin/bash

vm_name="chatapp-vm"
vm_zone="europe-west1-b"
frontend_service="chatapp-frontend.service"
backend_service="chatapp-backend.service"

# Stop the services
gcloud compute ssh $vm_name --zone $vm_zone --command "sudo systemctl stop $frontend_service"
gcloud compute ssh $vm_name --zone $vm_zone --command "sudo systemctl stop $backend_service"

# Pull the latest code
gcloud compute ssh $vm_name --zone $vm_zone --command "cd /chatapp-infra && sudo git reset --hard HEAD && sudo git pull"

# Copy the public folder
gcloud compute ssh $vm_name --zone $vm_zone --command "cd /chatapp-infra && sudo gsutil cp -r gs://chatapp-infra/public ./frontend/public"

# Start the services
gcloud compute ssh $vm_name --zone $vm_zone --command "sudo systemctl start $frontend_service"
gcloud compute ssh $vm_name --zone $vm_zone --command "sudo systemctl start $backend_service"
