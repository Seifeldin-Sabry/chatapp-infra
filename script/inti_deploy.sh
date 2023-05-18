#!/bin/bash

VM_NAME="instance-chatapp1"
REGION="europe-west1"
ZONE="europe-west1-b"
MACHINE_TYPE="e2-small"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
TARGET_TAGS="http-server,ssl-rule-tag,ssh,https-server,default-allow-ssh"
SQL_INSTANCE_NAME="chatapp"
DATABASE_NAME="chatapp"
SQL_ROOT_PASSWORD="chatapp"
DOMAIN_NAME="bottomchat.duckdns.org"
EMAIL="seifeldin.sabry@student.kdg.be"
NGINX_CONFIG="$(cat ./script/nginx_config)"
SYSTEMD_BACKEND_SERVICE_PATH="/etc/systemd/system/backend.service"
SYSTEMD_FRONTEND_SERVICE_PATH="/etc/systemd/system/frontend.service"

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
      curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
      apt-get install -y nodejs vite
      apt-get install -y nginx
      apt-get install -y postgresql postgresql-contrib
      apt-get install -y git
      apt-get install -y certbot python3-certbot-nginx
      service postgresql start
      ufw allow 'Nginx Full'
      ufw allow 'OpenSSH'
      ufw allow 'Nginx HTTP'
      ufw allow 'Nginx HTTPS'
      ufw allow 80
      ufw allow 443
      ufw allow 22
      ufw enable
      systemctl start nginx
      systemctl enable nginx
      echo \"$NGINX_CONFIG\" > /etc/nginx/sites-available/$DOMAIN_NAME
      ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/
      systemctl restart nginx
      git clone https://github.com/Seifeldin-Sabry/chatapp-infra.git /chatapp-infra
      while ! which certbot > /dev/null; do sleep 1; done
      certbot --nginx -d $DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL
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
  fi
  wait_for_psql
  gcloud compute scp ./sql/schema.sql "$VM_NAME":~/schema.sql --zone=$ZONE --project=infra3-seifeldin-sabry
  gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="echo $SQL_ROOT_PASSWORD | psql -h $SQL_INSTANCE_IP -U postgres -d $DATABASE_NAME -f ~/schema.sql"
}

function wait_for_psql() {
  echo "Waiting for psql to start"
  while ! gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="which psql"; do
    echo "psql not yet ready"
    sleep 1
  done
  echo "psql ready"
}

function start_app() {
  echo "Starting app"
  gcloud compute scp ./script/systemd_backend.service "$VM_NAME":~/backend.service --zone=$ZONE --project=infra3-seifeldin-sabry
  gcloud compute scp ./script/systemd_frontend.service "$VM_NAME":~/frontend.service --zone=$ZONE --project=infra3-seifeldin-sabry
  gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="sudo mv ~/backend.service /etc/systemd/system/backend.service"
  gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="sudo mv ~/frontend.service /etc/systemd/system/frontend.service"
  gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="sudo systemctl daemon-reload"
  gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="sudo systemctl start backend.service"
  gcloud compute ssh "$VM_NAME" --project=infra3-seifeldin-sabry --command="sudo systemctl start frontend.service"
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
start_app
