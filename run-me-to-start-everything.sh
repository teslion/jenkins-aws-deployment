#!/bin/bash
#to display time script started:
now=$(date)
echo "Time the script started: $now"
terraform init # needed only to initialize terraform
terraform destroy -auto-approve
terraform apply -auto-approve
#if you change the name of the project also change the name of keys in the line below too:
chmod 400 jenkins.pem
#to display time script started:
echo "Time the script ended: $now"
