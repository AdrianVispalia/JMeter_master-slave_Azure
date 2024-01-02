#!/bin/bash

az upgrade
az login

terraform init
terraform apply

# add the created VMs IPs to a group in /etc/ansible/hosts, and the respective keys
# don't forget to add the VMs in that 10s period phase. On the last step the servers will be up
ansible-playbook playbook.yml

jmeter -n -t ~/jmet/HTTP_Request.jmx -Djava.rmi.server.hostname=10.147.17.190 \  # hostname is server IP on network
                -R 10.147.17.75,10.147.17.232,10.147.17.96 -l your_results.jtl      # on -R list VMs IPs


awk -F',' '/Request,/ { print $6 "\t\t" $2 }' your_results.jtl
