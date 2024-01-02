# JMeter_master-slave_Azure

Project in order to test a website (latency, thorughput, etc.) from different VMs on different parts of the world.

Technologies used:
- JMeter
- Terraform
- Azure
- Zerotier
- Ansible

## Start

```bash
chmod +x run.sh
./run.sh
```

## Description

1. Terraform creates different VMs on different parts of the world using the Azure provider
2. Ansible configures all of the dependencies and installs the required components
3. All of the VMs connect through ZeroTier
4. The JMeter test file is run with the master/slave configuration

