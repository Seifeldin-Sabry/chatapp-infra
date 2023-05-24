### Deploying a Full Stack Chat Application

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
2. Having a Bucket already made in Gcloud for public assets in the frontend (change the bucket name in the script)

###### Steps:
1. Name the sql instance in the script however u like, it will create it if it doesnt exist
2. Name the Vm instance in the script however u like, it will create it if it doesnt exist
3. The script will create a VM machine that is setup with all the necessary dependencies and will clone the app on the VM
4. once it is cloned it will take the system config files to start the backend and frontend services and also take the nginx configuration for the proxy redirect
5. It also recursively copies the public assets from the bucket to the frontend folder since we dont track a public folder in git
6. And then a python script is run to make sure the DNS records are updated with the external ip of the VM instance so we should be able to [whatsapp](http://mocanupaulc.com) now


###### Updating the app:
When making changes to the app you can run the re-deploy script to update the app on the VM instance
<br>
###### How does it work:
1. it first stops the services
2. then it pulls the changes from the repo
3. then it copies the public assets from the bucket to the frontend folder
4. then it starts the services again

By [Mocanu Paul-Cristian](https://github.com/MocanuPaulC), [Seifeldin Sabry](https://github.com/Seifeldin-Sabry), [Nikola Velikov](https://github.com/Nixxion57)
