### Deploying a Full Stack Chat Application

For the full code navigate to the [chatapp-infra](https://github.com/Seifeldin-Sabry/chatapp-infra) repo


###### This project is a chat application that allows users to communicate with each other in real time using websockets.
##### Deployed using Gcloud Compute Engine and Cloud SQL. with VPC network peering between the two services to allow for private communication between the SQL instance and the Compute Engine instance.
##### Tech Stack:
1. Vite (Vue 3) for the frontend
2. Node/Express for the backend
3. PostgreSQL
4. Socket.io
5. TailwindCSS

You can log in, register and find others to chat with all with database operations.
<br>

##### How to Deploy:
###### Prerequisites:
1. Having a VPC network already made in Gcloud (change the network name in the script)
 - For the VPC network we disabled public ip of the sql instance and only enabled private, gcloud did all the automatic config, all we had to do was add the necessary firewall rules to allow the communication between the two services and to expost the VM instance to the internet
2. Having a Bucket already made in Gcloud for public assets in the frontend (change the bucket name in the script)

###### Steps:
1. Name the sql instance in the script however u like, it will create it if it doesnt exist
2. Name the Vm instance in the script however u like, it will create it if it doesnt exist
3. The script will create a VM machine that is setup with all the necessary dependencies and will clone the app on the VM
4. once it is cloned it will take the system config files to start the backend and frontend services and also take the nginx configuration for the proxy redirect
5. It also recursively copies the public assets from the bucket to the frontend folder since we dont track a public folder in git
6. And then a python script is run to make sure the DNS records are updated with the external ip of the VM instance so we should be able to [whatsapp](http://mocanupaulc.com) now
```shell
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
EMAIL="seifeldin.sabry@student.kdg.be"
DOMAINS="mocanupaulc.com,www.mocanupaulc.com"

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
      --metadata=startup-script="#!/bin/bash
      apt update && sudo apt upgrade -y
      sudo curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash -
      sudo apt-get install -y nodejs
      apt-get install -y vite postgresql postgresql-contrib git nginx certbot python3-certbot-nginx
      service postgresql start
      ufw allow 80
      ufw allow 443
      ufw allow 22
      nginx -t
      ufw enable
      git clone https://github.com/Seifeldin-Sabry/chatapp-infra.git /chatapp-infra
      git config --global --add safe.directory /chatapp-infra
      gsutil cp -r gs://chatapp-infra/public /chatapp-infra/frontend/public
      cp /chatapp-infra/script/systemd_backend.service /etc/systemd/system/chatapp-backend.service
      cp /chatapp-infra/script/systemd_frontend.service /etc/systemd/system/chatapp-frontend.service
      cp /chatapp-infra/script/nginx_config /etc/nginx/sites-available/default
      systemctl daemon-reload
      systemctl restart nginx
      certbot --nginx --non-interactive -m $EMAIL --agree-tos --domains=$DOMAINS
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
  if gcloud compute networks describe "$VPC_NAME" --project="$GOOGLE_PROJECT_ID" --quiet 1>/dev/null 2>/dev/null; then
    echo "VPC ${VPC_NAME} exists"
  else
    echo "VPC ${VPC_NAME} does not exist, please create it first"
    exit 1
  fi
}

check_vpc_network_exists
check_bucket_exists
create_vm
get_instance_ip
create_sql_instance
authorize_vm_to_instance
setup_database

```




###### Updating the app:
When making changes to the app you can run the re-deploy script to update the app on the VM instance
<br>
###### How does it work:
1. it first stops the services
2. then it pulls the changes from the repo
3. then it copies the public assets from the bucket to the frontend folder
4. then it starts the services again

```shell
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
  gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "echo $SQL_ROOT_PASSWORD | sudo psql -h $internal_ip -d $DB_NAME -U postgres -f /chatapp-infra/sql/schema.sql"
fi


# Copy the public folder
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "cd /chatapp-infra && sudo gsutil cp -r gs://chatapp-infra/public ./frontend/public"

# Start the services
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "sudo systemctl start $frontend_service"
gcloud compute ssh $vm_name --project $project_id --zone $vm_zone --command "sudo systemctl start $backend_service"
```

By [Mocanu Paul-Cristian](https://github.com/MocanuPaulC), [Seifeldin Sabry](https://github.com/Seifeldin-Sabry), [Nikola Velikov](https://github.com/Nixxion57)
