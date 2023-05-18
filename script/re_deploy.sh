#!/bin/bash

vm_name="chatapp-vm"
vm_zone="europe-west1-b"

gcloud compute ssh "$vm_name" --zone="$vm_zone" --command="cd /chatapp-infra && git pull && cd backend && npm install && npm run start && cd ../frontend && npm install && npm run build && npm run preview"
