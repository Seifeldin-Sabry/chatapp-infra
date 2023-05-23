#!/bin/bash

vm_name="chatapp-vm"
vm_zone="europe-west1-b"
frontend_service="chatapp-frontend.service"
backend_service="chatapp-backend.service"

gcloud compute ssh "$vm_name" --zone="$vm_zone" --command="sudo su && git config --global --add safe.directory /chatapp-infra && systemctl stop $frontend_service && systemctl stop $backend_service && cd /chatapp-infra && git reset --hard origin/main && git pull origin main && systemctl start $backend_service && systemctl start $frontend_service"

