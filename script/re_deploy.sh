#!/bin/bash

vm_name="chatapp-vm"
vm_zone="europe-west1-b"

gcloud compute ssh "$vm_name" --zone="$vm_zone" --command="sudo systemctl stop backend.service && sudo systemctl stop frontend.service"
gcloud compute ssh "$vm_name" --zone="$vm_zone" --command="sudo cd /chatapp-infra && git reset --hard origin/main && git pull origin main"
gcloud compute ssh "$vm_name" --zone="$vm_zone" --command="sudo systemctl start backend.service && sudo systemctl start frontend.service"

