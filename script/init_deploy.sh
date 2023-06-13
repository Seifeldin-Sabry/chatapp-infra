#!/bin/bash

VM_NAME="chatapp-vm"
REGION="europe-west1"
ZONE="europe-west1-b"
MACHINE_TYPE="e2-small"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
TARGET_TAGS="http-server,ssl-rule-tag,ssh,https-server,default-allow-ssh"
SQL_INSTANCE_NAME="chatapp"
DATABASE_NAME="chatapp"
SQL_ROOT_PASSWORD="chatapp"
VPC_NAME="chatapp-vpc"
BUCKET_NAME="chatapp-infra"

function create_vm() {
  if gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --project="$GOOGLE_PROJECT_ID" --quiet 1>/dev/null 2>/dev/null; then
    echo "VM ${VM_NAME} already exists"
  fi
  gcloud compute instances create "$VM_NAME" \
      --zone="$ZONE" \
      --network="$VPC_NAME" \
      --machine-type="$MACHINE_TYPE" \
      --tags="$TARGET_TAGS" \
      --image-family="$IMAGE_FAMILY" \
      --image-project="$IMAGE_PROJECT" \
      --metadata=startup-script=gs://$BUCKET_NAME/startup.sh
}

function authorize_vm_to_instance() {
# Get the list of current authnw
  current_authnw=$(gcloud sql instances describe "$SQL_INSTANCE_NAME" \
    --format='value(settings.ipConfiguration.authorizedNetworks[].value)' \
    | tr ";" ",");

  echo "Current authnw: ${current_authnw}"
  if [[ -z ${current_authnw} || ${current_authnw} = "0.0.0.0/0" ]]; then
    gcloud sql instances patch "$SQL_INSTANCE_NAME" --authorized-networks="${VM_IP}" -q
  else
    current_authnw+=,${VM_IP}
    gcloud sql instances patch "$SQL_INSTANCE_NAME" \
        --authorized-networks="${current_authnw}" -q
  fi
}

function get_instance_ip() {
  echo "Getting VM IP"
  VM_IP=$(gcloud compute instances describe "$VM_NAME" --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)
  export IP_ADDRESS=$VM_IP
  python3 ./script/dnsSetup.py
  echo "VM IP is $VM_IP"
}

function create_sql_instance() {
  if gcloud sql instances describe "$SQL_INSTANCE_NAME" \
    --quiet 1>/dev/null 2>/dev/null; then
    echo "SQL instance ${SQL_INSTANCE_NAME} already exists"
    SQL_INSTANCE_IP=$(gcloud sql instances describe "$SQL_INSTANCE_NAME" \
      --format="get(ipAddresses[0].ipAddress)" 2>/dev/null)
    return
  fi
  echo "Creating SQL instance"
  gcloud sql instances create "$SQL_INSTANCE_NAME" \
    --database-version=POSTGRES_14 \
    --cpu=1 \
    --memory=3840MiB \
    --region="$REGION" \
    --root-password="$SQL_ROOT_PASSWORD" \
    --storage-type=HDD

  SQL_INSTANCE_IP=$(gcloud sql instances describe "$SQL_INSTANCE_NAME" \
    --format="get(ipAddresses[0].ipAddress)" 2>/dev/null)
}

function setup_database() {
  echo "Setting up database"
  if gcloud sql databases describe "$DATABASE_NAME" \
    --instance="$SQL_INSTANCE_NAME" \
    --quiet 1>/dev/null 2>/dev/null; then
    echo "Database ${DATABASE_NAME} already exists"
  else
    gcloud sql databases create $DATABASE_NAME \
    --instance="$SQL_INSTANCE_NAME"
    wait_for_psql
    gcloud compute scp ./sql/schema.sql "$VM_NAME":~/schema.sql --zone=$ZONE --project=infra3-seifeldin-sabry
    gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="echo $SQL_ROOT_PASSWORD | psql -h $SQL_INSTANCE_IP -U postgres -d $DATABASE_NAME -f ~/schema.sql"
  fi
}

function wait_for_psql() {
  echo "Waiting for psql to start"
  while ! gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="which psql"; do
    echo "psql not yet ready"
    sleep 1
  done
  echo "psql ready"
}

function check_bucket_exists() {
  if gsutil ls -b gs://"$BUCKET_NAME" 1>/dev/null 2>/dev/null; then
    echo "Bucket ${BUCKET_NAME} exists"
  else
    echo "Bucket ${BUCKET_NAME} does not exist, please create it first"
    exit 1
  fi
}

function check_vpc_network_exists() {
  if gcloud compute networks describe "$VPC_NAME" --quiet 1>/dev/null 2>/dev/null; then
    echo "VPC ${VPC_NAME} exists"
  else
    echo "VPC ${VPC_NAME} does not exist, please create it first"
    exit 1
  fi
}

function copy_startup_script_to_bucket() {
  gsutil cp ./script/startup.sh gs://"$BUCKET_NAME"/startup.sh
}

check_vpc_network_exists
check_bucket_exists
copy_startup_script_to_bucket
create_vm
get_instance_ip
create_sql_instance
authorize_vm_to_instance
setup_database
