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
DOMAIN_NAME="globalchat.tech"
EMAIL="seifeldin.sabry@student.kdg.be"
PROJECT_ID="infra3-seifeldin-sabry"
VPC_NAME="chatapp-vpc"
SUBNET_NAME="chatapp-subnet"

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
      apt update && sudo apt upgrade -y
      sudo curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash -
      sudo apt-get install -y nodejs
      apt-get install -y vite postgresql postgresql-contrib git certbot nginx python3-certbot-nginx
      service postgresql start
      ufw allow 80
      ufw allow 443
      ufw allow 22
      ufw allow 'Nginx Full'
      ufw allow 'OpenSSH'
      nginx -t
      ufw enable
      git clone https://github.com/Seifeldin-Sabry/chatapp-infra.git /chatapp-infra
#      while ! which certbot > /dev/null; do sleep 1; done
      cp /chatapp-infra/script/systemd_backend.service /etc/systemd/system/chatapp-backend.service
      cp /chatapp-infra/script/systemd_frontend.service /etc/systemd/system/chatapp-frontend.service
      cp /chatapp-infra/script/nginx_config /etc/nginx/sites-available/default
      systemctl daemon-reload
#      make self signed certificate
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj \"/C=BE/ST=Antwerp/L=Antwerp/O=KdG/OU=IT/CN=$DOMAIN_NAME\"
      openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
      cp /chatapp-infra/script/self-signed.conf /etc/nginx/snippets/self-signed.conf
      cp /chatapp-infra/script/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
      cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
      systemctl restart nginx
#      certbot --standalone -d $DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL -w /chatapp-infra/frontend/dist
      systemctl start chatapp-backend.service
      systemctl start chatapp-frontend.service
      "
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


# Function to configure GCloud Storage for static files with open access
#function configure_gcloud_storage() {
#  # Create the GCloud Storage bucket
#  gsutil mb gs://"$BUCKET_NAME"
#  # Upload static files to the bucket
#  gsutil -m cp -r "$STATIC_FILES_DIR/*" gs://"$BUCKET_NAME"/
#  # Set appropriate permissions on the bucket
#  gsutil -m acl ch -r -u allUsers:R gs://"$BUCKET_NAME"
#}

# Call the function to configure GCloud Storage for static files
# configure_gcloud_storage

create_vm
get_instance_ip
create_sql_instance
authorize_vm_to_instance
setup_database
