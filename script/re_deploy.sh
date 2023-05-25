#!/bin/bash

vm_name="chatapp-vm"
vm_zone="europe-west1-b"
frontend_service="chatapp-frontend.service"
backend_service="chatapp-backend.service"
project_id="infra3-seifeldin-sabry"
SQL_ROOT_PASSWORD="chatapp"
DB_NAME="chatapp"
SQL_INSTANCE_NAME="chatapp"

# Stop the services
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "sudo systemctl stop $frontend_service"
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "sudo systemctl stop $backend_service"

# Pull the latest code
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "cd /chatapp-infra && sudo git reset --hard HEAD && sudo git pull"

# if parameter 1 is passed "db" then update the schema
if [ "$1" == "db" ]; then
  internal_ip=$(gcloud compute instances describe $vm_name --project $project_id --zone $vm_zone --format="get(networkInterfaces[0].networkIP)")
  echo "Internal IP is $internal_ip"
  gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "echo $SQL_ROOT_PASSWORD | sudo -S -h $internal_ip -d $DB_NAME -u postgres psql -f /chatapp-infra/sql/schema.sql"
fi


# Copy the public folder
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "cd /chatapp-infra && sudo gsutil cp -r gs://chatapp-infra/public ./frontend/public"

# Start the services
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "sudo systemctl start $frontend_service"
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "sudo systemctl start $backend_service"
