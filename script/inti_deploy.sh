#!/bin/bash

VM_NAME="VM-$(date +%s)"
REGION="europe-west1"
ZONE="europe-west1-b"
MACHINE_TYPE="e2-small"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
TARGET_TAGS="http-server,ssl-rule-tag,ssh,https-server,default-allow-ssh"
SQL_INSTANCE_NAME="chatapp"
SQL_ROOT_PASSWORD="chatapp"


function create_vm() {
  if gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --project="$GOOGLE_PROJECT_ID" --quiet 1>/dev/null 2>/dev/null; then
    echo "VM ${VM_NAME} already exists"
  fi
  gcloud compute instances create "$VM_NAME" \
      --zone="$ZONE" \
      --machine-type="$MACHINE_TYPE" \
      --tags="$TARGET_TAGS" \
      --image-family="$IMAGE_FAMILY" \
      --image-project="$IMAGE_PROJECT" \
      --metadata=startup-script="#!/bin/bash
      apt-get update
      curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
      apt-get install -y nodejs
      apt-get install -y npm
      apt-get install -y postgresql postgresql-contrib
      "
}

function authorize_vm_to_instance() {
#  use gcloud instances list to find the instance, if not exist exit 1
 if ! gcloud sql instances list | grep "$SQL_INSTANCE_NAME" 1>/dev/null 2>/dev/null; then
    echo "Instance $SQL_INSTANCE_NAME does not exist"
    create_sql_instance
  fi
# Get the list of current authnw
  current_authnw=$(gcloud sql instances describe "$SQL_INSTANCE_NAME" \
    --format='value(settings.ipConfiguration.authorizedNetworks[].value)' \
    |tr ";" ",")
  if [[ -z ${current_authnw} || ${current_authnw} = "0.0.0.0/0" ]]; then
    gcloud sql instances patch "$SQL_INSTANCE_NAME" --authorized-networks="${VM_IP}" -q
  else
    current_authnw+=,${VM_IP}
    gcloud sql instances patch "$SQL_INSTANCE_NAME" \
        --authorized-networks="${current_authnw}" -q
  fi
}

function create_sql_instance() {
  echo "Creating SQL instance"
  gcloud sql instances create "$SQL_INSTANCE_NAME" \
    --database-version=POSTGRES_14 \
    --cpu=1 \
    --memory=3840MiB \
    --region="$REGION" \
    --project="$GOOGLE_PROJECT_ID" \
    --root-password="$SQL_ROOT_PASSWORD" \
    --storage-type=HDD \
    --tier=db-f1-micro
}

function setup_database() {
  echo "Setting up database"
  gcloud sql databases create chatapp \
    --instance="$SQL_INSTANCE_NAME"
  gcloud sql users create chatapp \
    --instance="$SQL_INSTANCE_NAME" \
    --password="$SQL_ROOT_PASSWORD"
  gcloud ssh "$VM_NAME" --zone="$ZONE" --command="
}
